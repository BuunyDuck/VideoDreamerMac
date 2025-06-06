//
//  ConnectionsListView.m
//  VideoFrame
//
//  Created by Yinjing Li on 08/21/17.
//  Copyright (c) 2017 Yinjing Li. All rights reserved.
//


#import "ConnectionsListView.h"
#import "SceneDelegate.h"

@implementation ConnectionsListView

@synthesize titleLabel, connectionsListTable;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        self.backgroundColor = [UIColor blackColor];
        
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 2.0f;

        CGFloat rTitleLabelHeight = 52.0f;
        CGFloat rFontSize = 20.0f;
        
        CGFloat rHeight = 0.0f;
        BOOL scrollEnable = NO;
        NSInteger nMaxVisible = 5;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            nMaxVisible = 4;
        else
            nMaxVisible = 10;
        
        if (self.appDelegate.projectSharingManager.mySession.connectedPeers.count > nMaxVisible)
        {
            rHeight = rTitleLabelHeight * (nMaxVisible + 1) + 10.0f;
            scrollEnable = YES;
        }
        else
        {
            rHeight = rTitleLabelHeight * (self.appDelegate.projectSharingManager.mySession.connectedPeers.count + 1) + 10.0f;
        }
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, rHeight);
        
        // Title label
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, rTitleLabelHeight)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = NSLocalizedString(@"Send projects", nil);
        self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize+2];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.1f;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];
        
        //ConnectionsListTableView
        self.connectionsListTable = nil;
        self.connectionsListTable = [[UITableView alloc] initWithFrame:CGRectMake(5.0f, rTitleLabelHeight + 5.0f, self.frame.size.width - 10.0f, self.frame.size.height - rTitleLabelHeight - 10.0f) style:UITableViewStylePlain];
        self.connectionsListTable.delegate = self;
        self.connectionsListTable.dataSource = self;
        self.connectionsListTable.backgroundColor = [UIColor clearColor];
        self.connectionsListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.connectionsListTable.scrollEnabled = scrollEnable;
        [self addSubview:self.connectionsListTable];
        
        [self.connectionsListTable reloadData];
    }
    
    return self;
}


#pragma mark -
#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appDelegate.projectSharingManager.mySession.connectedPeers.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	
	ConnectionsListCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[ConnectionsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier index:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }

    cell.tag = indexPath.row;

    cell.deviceNameLabel.text = [self.appDelegate.projectSharingManager.mySession.connectedPeers objectAtIndex:indexPath.row].displayName;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0f;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return proposedDestinationIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Change the selected background view of the cell.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark
#pragma marl - ConnectionsListCellDelegate

-(void) didSelectedSendProjectToConnection:(NSInteger) connectionIndex
{
    self.nSendIndex = 0;

    NSLog(@"send a project to %@", [self.appDelegate.projectSharingManager.mySession.connectedPeers objectAtIndex:connectionIndex].displayName);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Sending...", nil)) isLock:YES];
    });
    
    if ([self.delegate respondsToSelector:@selector(didTapSendProject)])
    {
        [self.delegate didTapSendProject];
    }
    
    [self performSelector:@selector(sendProject:) withObject:[NSNumber numberWithInteger:connectionIndex] afterDelay:0.02f];
}

-(void) sendProject:(NSNumber *)indexNumber
{
    NSInteger connectionIndex = [indexNumber integerValue];
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString* projectName = [self.projectNamesArray objectAtIndex:self.nSendIndex];
    NSString* projectPath = [documentsPath stringByAppendingPathComponent:projectName];
    
    NSString* zipFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", projectName]];
    unlink([zipFilePath UTF8String]);
    
    @autoreleasepool
    {
        [SSZipArchive createZipFileAtPath:zipFilePath withContentsOfDirectory:projectPath];
    }
    
    //Save zip file to iCloud
    NSURL* zipUrl = [NSURL fileURLWithPath:zipFilePath];
    
    MCPeerID* receivePeerID = [self.appDelegate.projectSharingManager.mySession.connectedPeers objectAtIndex:connectionIndex];
    
    [self.appDelegate.projectSharingManager.mySession sendResourceAtURL:zipUrl withName:projectName toPeer:receivePeerID withCompletionHandler:^(NSError * _Nullable error) {
        
        self.nSendIndex++;
        
        if (self.nSendIndex >= self.projectNamesArray.count)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
               
                [[SHKActivityIndicator currentIndicator] hide];
                
                [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Completed!", nil) message:NSLocalizedString(@"You sent a project successfully!", nil) okHandler:nil];
            });
        }
        else
        {
            [self sendProject:[NSNumber numberWithInteger:connectionIndex]];
        }
    }];
}

@end
