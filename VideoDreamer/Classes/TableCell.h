//
//  TableCell.h
//  VideoFrame
//
//  Created by APPLE on 5/28/19.
//  Copyright © 2019 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@protocol editCellDelegate <NSObject>
@optional
-(void) editButtonDidSelected:(NSInteger) index;

@end

@interface TableCell : UITableViewCell<UIGestureRecognizerDelegate>
{
    
}

@property(nonatomic, weak) id <editCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *nameCellLabel;

@property (strong, nonatomic) IBOutlet UILabel *urlCellLabel;
@property (strong, nonatomic) IBOutlet UIButton *cellEditButton;

-(void) reloadCell:(NSInteger) nIndex;

@end
