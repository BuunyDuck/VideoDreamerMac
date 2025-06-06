//
//  ProjectSharingManager.h
//  VideoFrame
//
//  Created by APPLE on 8/18/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSZipArchive.h"
#import "CustomProgressBar.h"

@import MultipeerConnectivity;

@protocol ProjectSharingManagerDelegate;



@interface ProjectSharingManager : NSObject <MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property (nonatomic, weak) id <ProjectSharingManagerDelegate> projectSharingManagerDelegate;

@property(nonatomic, strong) MCPeerID* myPeerID;
@property(nonatomic, strong) MCSession* mySession;
@property(nonatomic, strong) MCNearbyServiceAdvertiser* myServiceAdvertiser;
@property(nonatomic, strong) MCNearbyServiceBrowser* myServiceBrowser;
@property(nonatomic, strong) NSProgress* myProgress;
@property(nonatomic, assign) BOOL isRunning;

-(BOOL) checkAvailablePeersForReceiving;

-(NSArray *) shareZippedProjects:(NSArray *)projectNames;

@end


@protocol ProjectSharingManagerDelegate <NSObject>

@optional

-(void) connectedDevicesChanged:(ProjectSharingManager*) projectSharingManager devices:(NSString*) connectedDevices;

@end
