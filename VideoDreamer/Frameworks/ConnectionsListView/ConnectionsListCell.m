//
//  ConnectionsListCell.m
//  VideoFrame
//
//  Created by Yinjing Li on 08/21/17.
//  Copyright (c) 2017 Yinjing Li. All rights reserved.
//


#import "ConnectionsListCell.h"
#import "Definition.h"


@implementation ConnectionsListCell:UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSInteger) nIndex
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.frame = CGRectMake(0, 0, 270.0f, 52.0f);
        else
            self.frame = CGRectMake(0, 0, 390.0f, 52.0f);
        
        self.tag = nIndex;

        CGFloat fontSize = 18.0f;
        
        self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1.0f, self.frame.size.width, 50.0f)];
        self.bgImageView.image = [UIImage imageNamed:@"filterCellBg"];
        [self.contentView addSubview:self.bgImageView];
        
        self.deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 1.0f, self.frame.size.width - 95.0f, 50.0f)];
        self.deviceNameLabel.text = @"device";
        self.deviceNameLabel.backgroundColor = [UIColor clearColor];
        self.deviceNameLabel.textAlignment = NSTextAlignmentLeft;
        self.deviceNameLabel.font = [UIFont fontWithName:MYRIADPRO size:fontSize];
        self.deviceNameLabel.adjustsFontSizeToFitWidth = YES;
        self.deviceNameLabel.minimumScaleFactor = 0.1f;
        self.deviceNameLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.deviceNameLabel];
        
        self.applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.applyButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
        [self.applyButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateSelected];
        [self.applyButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        self.applyButton.backgroundColor = [UIColor clearColor];
        self.applyButton.frame = CGRectMake(self.frame.size.width - 85.0f, 6.0f, 80.0f, 40.0f);
        [self.applyButton addTarget:self action:@selector(didSelected:) forControlEvents:UIControlEventTouchUpInside];
        self.applyButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.applyButton.layer.borderWidth = 1.0f;
        self.applyButton.layer.cornerRadius = 2.0f;
        [self.contentView addSubview:self.applyButton];
    }
    
    return self;
}


// tapped a "Send" button

- (void) didSelected:(id) sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectedSendProjectToConnection:)])
    {
        [self.delegate didSelectedSendProjectToConnection:self.tag];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


@end
