//
//  FilterListCell.h
//  VideoFrame
//
//  Created by Yinjing Li on 12/1/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FilterSelectDelegate <NSObject>
@optional
-(void) filterPreviewDidSelected:(NSInteger) index;
-(void) filterApplyDidSelected:(NSInteger) index;

@end


@interface FilterListCell: UITableViewCell
{
    
}

@property(nonatomic, weak) id <FilterSelectDelegate> delegate;

@property(nonatomic, strong) UIImageView* bgImageView;

@property(nonatomic, strong) UILabel* filterNameLabel;

@property(nonatomic, strong) UIButton* applyButton;
@property(nonatomic, strong) UIButton* previewButton;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSInteger) nIndex;

-(void) reloadCell:(NSInteger) nIndex;


@end
