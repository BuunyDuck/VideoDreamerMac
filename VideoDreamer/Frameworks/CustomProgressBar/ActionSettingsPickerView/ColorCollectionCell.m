//
//  ColorCollectionCell.m
//  VideoDreamer
//
//  Created by Mobile Master on 4/12/23.
//

#import "ColorCollectionCell.h"

@implementation ColorCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setColor:(UIColor *)color {
    _color = color;
    
    self.contentView.backgroundColor = color;
}

@end
