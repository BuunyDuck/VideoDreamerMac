//
//  ProjectSharingManager.m
//  VideoFrame
//
//  Created by APPLE on 8/18/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import "ProjectSharingManager.h"
#import "SceneDelegate.h"

@implementation ProjectSharingManager

#define ProjectSharingServiceType @"vf-proshare"

-(id) init
{
    self = [super init];
    
    if (self)
    {
        self.myPeerID = nil;
        self.mySession = nil;
        self.myServiceAdvertiser = nil;
        self.myServiceBrowser = nil;
        
        [self setupPeerAndSession];
        [self setupAdvertise];
    }
    
    return self;
}

-(void) setupPeerAndSession
{
    self.myPeerID = [[MCPeerID alloc] initWithDisplayName:UIDevice.currentDevice.name];
    
    self.mySession = [[MCSession alloc] initWithPeer:self.myPeerID];
    self.mySession.delegate = self;
}

-(void) setupAdvertise
{
    self.myServiceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.myPeerID discoveryInfo:nil serviceType:ProjectSharingServiceType];
    self.myServiceAdvertiser.delegate = self;
    [self.myServiceAdvertiser startAdvertisingPeer];
    
    self.myServiceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.myPeerID serviceType:ProjectSharingServiceType];
    self.myServiceBrowser.delegate = self;
    [self.myServiceBrowser startBrowsingForPeers];
}

-(BOOL) checkAvailablePeersForReceiving
{
    return self.mySession.connectedPeers.count > 0 ? YES : NO;
}

-(NSArray *) shareZippedProjects:(NSArray *)projectNames {
    NSMutableArray *zipPaths = [NSMutableArray array];
    for (NSString *projectName in projectNames) {
        NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString* projectPath = [documentsPath stringByAppendingPathComponent:projectName];
        
        NSString* zipFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", projectName]];
        unlink([zipFilePath UTF8String]);
        
        @autoreleasepool
        {
            [SSZipArchive createZipFileAtPath:zipFilePath withContentsOfDirectory:projectPath];
            [zipPaths addObject:[NSURL fileURLWithPath:zipFilePath]];
        }
    }
    
    return zipPaths;
}

#pragma mark -
#pragma mark - MCNearbyServiceAdvertiserDelegate

-(void) advertiser:(MCNearbyServiceAdvertiser *)advertiser
        didReceiveInvitationFromPeer:(MCPeerID *)peerID
        withContext:(nullable NSData *)context
        invitationHandler:(void (^)(BOOL accept, MCSession * __nullable session))invitationHandler
{
    NSLog(@"didReceiveInvitationFromPeer: %@", peerID);
    
    invitationHandler(true, self.mySession);
}

-(void) advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"didNotStartAdvertisingPeer error: %@", error);
}


#pragma mark -
#pragma mark - MCNearbyServiceBrowserDelegate

-(void) browser:(MCNearbyServiceBrowser *)browser
        foundPeer:(MCPeerID *)peerID
        withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info
{
    NSLog(@"foundPeer: %@", peerID);

    //send invitation to found peer
    [browser invitePeer:peerID toSession:self.mySession withContext:nil timeout:10];
}

-(void) browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"lostPeer: %@", peerID);
}

-(void) browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"didNotStartBrowsingForPeers error: %@", error);
}


#pragma mark -
#pragma mark - MCSessionDelegate

-(void) session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"peer %@ didChangeState: %ld", peerID, (long)state);
    
    if ([self.projectSharingManagerDelegate respondsToSelector:@selector(connectedDevicesChanged:devices:)])
    {
        [self.projectSharingManagerDelegate connectedDevicesChanged:self devices:peerID.displayName];
    }
}

-(void) session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"didReceiveData %@", data);
}

-(void) session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"didReceiveStream");
}


// start receiving resource
-(void) session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"didStartReceivingResourceWithName - resource name:%@, from %@", resourceName, peerID.displayName);
    
    self.isRunning = !self.isRunning;
    
    self.myProgress = progress;
    [self.myProgress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionInitial context:nil];

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[CustomProgressBar currentProgressBar] displayProgressBar:(NSLocalizedString(@"Receiving...", nil)) isLock:YES];
        
    });
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSProgress *progress = object;
        
        [[CustomProgressBar currentProgressBar] updateProgressBar:progress.fractionCompleted];
        
        NSLog(@"Progress - %f", progress.fractionCompleted);
    }];
}

// finish receiving resource
-(void) session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"didFinishReceivingResourceWithName - resource name:%@, from %@, received at %@", resourceName, peerID.displayName, localURL.path);
    
    //create directory for received project
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString* savePath = [documentsPath stringByAppendingPathComponent:resourceName];
    
    NSError* localError = nil;
    
    if ([localFileManager fileExistsAtPath:savePath])
        [localFileManager removeItemAtPath:savePath error:&localError];
    
    [localFileManager createDirectoryAtPath:savePath withIntermediateDirectories:NO attributes:nil error:nil];

    
    //unzip received project zip file to document directory
    NSString* zipFilePath = [localURL path];
    
    @autoreleasepool
    {
        [SSZipArchive unzipFileAtPath:zipFilePath toDestination:savePath];
    }
    
    unlink([zipFilePath UTF8String]);

    dispatch_async(dispatch_get_main_queue(), ^{
       
        NSString* strText = NSLocalizedString(@"You received a project", nil);
        strText = [strText stringByAppendingString:[NSString stringWithFormat:@" \"%@\" ", resourceName]];
        strText = [strText stringByAppendingString:NSLocalizedString(@"from", nil)];
        strText = [strText stringByAppendingString:[NSString stringWithFormat:@" %@.", peerID.displayName]];

        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Completed!", nil) message:strText preferredStyle:UIAlertControllerStyleAlert];
        
        [[SceneDelegate sharedDelegate].navigationController.visibleViewController presentViewController:alertController animated:YES completion:nil];
        
        [self performSelector:@selector(dismissAlertView:) withObject:alertController afterDelay:0.5f];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivedProjectNotification" object:self];
        
        if (self.isRunning)
        {
            self.isRunning = NO;
            [[CustomProgressBar currentProgressBar] hide];
        }
        else
            self.isRunning = YES;
    });
    
    [self.myProgress removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                     context:nil];
}

-(void)dismissAlertView:(UIAlertController*) alertController
{
    [alertController dismissViewControllerAnimated:YES completion:nil];
}

@end
