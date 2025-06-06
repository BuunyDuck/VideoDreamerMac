//
//  ProjectListViewController.h
//  VideoFrame
//
//  Created by YinjingLi on 1/14/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "CustomModalView.h"
#import "ConnectionsListView.h"


@class ProjectGalleryPickerController;


@interface ProjectListViewController : UIViewController <CustomModalViewDelegate, ConnectionsListViewDelegate>
{
    BOOL isSelectAll;
    
    int selectedProjectCount;
}

@property(nonatomic, assign) BOOL isBackup;
@property(nonatomic, assign) BOOL isSharing;
@property(nonatomic, assign) int saveCount;

@property(nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property(nonatomic, strong) UIBarButtonItem *backupRestoreButton;
@property(nonatomic, strong) UIBarButtonItem *shareProjectButton;
@property(nonatomic, strong) UIBarButtonItem *selectAllButton;

@property(nonatomic, strong) IBOutlet UITableView* projectListTableView;


@property(nonatomic, strong) NSMutableArray* projectNamesArray;
@property(nonatomic, strong) NSMutableArray* projectThumbnailArray;
@property(nonatomic, strong) NSMutableArray* projectSelectionFlagArray;

@property(nonatomic, strong) NSMetadataQuery* query;

@property(nonatomic, strong) ProjectGalleryPickerController* projectGalleryPickerController;

@property(nonatomic, strong) CustomModalView* customModalView;
@property(nonatomic, strong) ConnectionsListView* connectionsListView;
@property(nonatomic, strong) AppDelegate *appDelegate;

@end
