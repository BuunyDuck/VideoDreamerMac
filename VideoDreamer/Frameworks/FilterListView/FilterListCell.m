//
//  FilterListCell.m
//  VideoFrame
//
//  Created by Yinjing Li on 12/1/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//


#import "FilterListCell.h"
#import "Definition.h"


@implementation FilterListCell: UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSInteger) nIndex
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.frame = CGRectMake(0, 0, 240.0f, 54.0f);
        else
            self.frame = CGRectMake(0, 0, 300.0f, 54.0f);
        
        self.tag = nIndex;

        CGFloat fontSize = 18.0f;
        
        self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, self.frame.size.width, 52.0f)];
        self.bgImageView.image = [UIImage imageNamed:@"filterCellBg"];
        [self addSubview:self.bgImageView];
        
        self.previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.previewButton setImage:[UIImage imageNamed:@"previewButton"] forState:UIControlStateNormal];
        self.previewButton.backgroundColor = [UIColor clearColor];
        self.previewButton.frame = CGRectMake(5.0f, 7.0f, 40.0f, 40.0f);
        [self.previewButton addTarget:self action:@selector(onPreview:) forControlEvents:UIControlEventTouchUpInside];
        self.previewButton.selected = YES;
        [self.contentView addSubview:self.previewButton];
        
        self.filterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0f, 3.0f, self.frame.size.width - 108.0f, 50.0f)];
        self.filterNameLabel.text = (nIndex==0) ? NSLocalizedString(@"NORMAL", nil) : NSLocalizedString(@"CHROMAKEY", nil);
        self.filterNameLabel.backgroundColor = [UIColor clearColor];
        self.filterNameLabel.textAlignment = NSTextAlignmentCenter;
        self.filterNameLabel.font = [UIFont fontWithName:MYRIADPRO size:fontSize];
        self.filterNameLabel.adjustsFontSizeToFitWidth = YES;
        self.filterNameLabel.minimumScaleFactor = 0.1f;
        self.filterNameLabel.textColor = [UIColor lightGrayColor];
        self.filterNameLabel.shadowColor = [UIColor whiteColor];
        self.filterNameLabel.shadowOffset = CGSizeMake(0, 1);
        [self.contentView addSubview:self.filterNameLabel];
        
        self.applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.applyButton setImage:[UIImage imageNamed:@"applyButton"] forState:UIControlStateNormal];
        self.applyButton.backgroundColor = [UIColor clearColor];
        self.applyButton.frame = CGRectMake(self.frame.size.width - 44.0f, 7.0f, 40.0f, 40.0f);
        [self.applyButton addTarget:self action:@selector(onApply:) forControlEvents:UIControlEventTouchUpInside];
        self.applyButton.selected = YES;
        [self.contentView addSubview:self.applyButton];
    }
    
    return self;
}

- (void) reloadCell:(NSInteger) nIndex
{
    self.filterNameLabel.text = (nIndex==0) ? NSLocalizedString(@"NORMAL", nil) : NSLocalizedString(@"CHROMAKEY", nil);
    self.tag = nIndex;
}

- (void) onPreview:(id) sender
{
    if ([self.delegate respondsToSelector:@selector(filterPreviewDidSelected:)])
    {
        [self.delegate filterPreviewDidSelected:[self tag]];
    }
}

- (void) onApply:(id) sender
{
    if ([self.delegate respondsToSelector:@selector(filterApplyDidSelected:)])
    {
        [self.delegate filterApplyDidSelected:[self tag]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


@end
