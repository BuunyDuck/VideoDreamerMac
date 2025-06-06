//
//  MusicDownloadWebVC.h
//  VideoFrame
//
//  Created by APPLE on 11/14/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableCell.h"
#import "AppDelegate.h"
#import "Definition.h"

@class Music;
@class MusicDownload;
@class MusicInputVC;
@class MusicDownloadController;

@interface MusicDownloadVC : UIViewController<UIGestureRecognizerDelegate, NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, UITableViewDelegate, UITableViewDataSource, editCellDelegate>
{
    IBOutlet UITableView *tableView;
    
    NSMutableArray *musicList;
    Music *music;
    MusicDownloadController *musicDownloadController;
}

@property(nonatomic, weak) MusicDownload* musicDownload;
@property(nonatomic, retain) Music *music;
@property(nonatomic, retain) MusicInputVC *musicInputVC;

@end
