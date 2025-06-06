//
//  ConnectionsListCell.h
//  VideoFrame
//
//  Created by Yinjing Li on 08/21/17.
//  Copyright (c) 2017 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ConnectionsListCellDelegate <NSObject>

@optional
-(void) didSelectedSendProjectToConnection:(NSInteger) connectionIndex;

@end


@interface ConnectionsListCell:UITableViewCell

@property(nonatomic, weak) id <ConnectionsListCellDelegate> delegate;

@property(nonatomic, strong) UIImageView* bgImageView;

@property(nonatomic, strong) UILabel* deviceNameLabel;

@property(nonatomic, strong) UIButton* applyButton;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSInteger) nIndex;


@end
