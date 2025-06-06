//
//  TableCell.m
//  VideoFrame
//
//  Created by APPLE on 5/28/19.
//  Copyright © 2019 Yinjing Li. All rights reserved.
//

#import "TableCell.h"
#import "Definition.h"

@implementation TableCell:UITableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)reloadCell:(NSInteger)nIndex
{
    self.tag = nIndex;
}

- (IBAction)actionEditCell:(id)sender {
    if ([self.delegate respondsToSelector:@selector(editButtonDidSelected:)])
    {
        [self.delegate editButtonDidSelected:[self tag]];
    }
}

@end
