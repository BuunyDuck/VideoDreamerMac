//
//  ConnectionsListView.h
//  VideoFrame
//
//  Created by Yinjing Li on 08/21/17.
//  Copyright (c) 2017 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Definition.h"
#import "AppDelegate.h"
#import "SSZipArchive.h"
#import "SHKActivityIndicator.h"

#import "ConnectionsListCell.h"

@protocol ConnectionsListViewDelegate <NSObject>

@optional
-(void) didTapSendProject;

@end

@interface ConnectionsListView : UIView<UITableViewDelegate, UITableViewDataSource, ConnectionsListCellDelegate>

@property(nonatomic, weak) id <ConnectionsListViewDelegate> delegate;

@property(nonatomic, strong) UILabel* titleLabel;

@property(nonatomic, strong) UITableView* connectionsListTable;

@property(nonatomic, strong) AppDelegate *appDelegate;

@property(nonatomic, strong) NSMutableArray* projectNamesArray;

@property(nonatomic, assign) NSInteger nSendIndex;

@end
