//
//  MusicCell.m
//  VideoFrame
//
//  Created by Yinjing Li on 5/12/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "MusicCell.h"
#import "Definition.h"
#import "SceneDelegate.h"

@implementation MusicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.isPlaying = NO;
        
        CGRect frame = self.textLabel.frame;
        self.titleLabel = [[UILabel alloc] initWithFrame:frame];
        self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]];
        self.titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.titleLabel];
        
        frame.size.width -= 64.0;
        self.nameTextField = [[UITextField alloc] initWithFrame:frame];
        [self.nameTextField setBackgroundColor:[UIColor clearColor]];
        [self.nameTextField setTextColor:[UIColor blackColor]];
        [self.nameTextField setTextAlignment:NSTextAlignmentLeft];
        self.nameTextField.delegate = self;
        self.nameTextField.userInteractionEnabled = NO;
        self.nameTextField.font = [UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]];
        [self.contentView addSubview:self.nameTextField];
        
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat x = self.detailTextLabel.frame.origin.x - self.frame.size.height;
        [self.playButton setFrame:CGRectMake(x, 5.0f, self.frame.size.height - 10.0f, self.frame.size.height - 10.0f)];
        [self.playButton setBackgroundColor:[UIColor clearColor]];
        [self.playButton setImage:[UIImage imageNamed:@"PlayMusic"] forState:UIControlStateNormal];
        [self.playButton addTarget:self action:@selector(playbuttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.playButton];
    }
    
    return self;
}

- (void)playbuttonTapped:(id) sender
{
    if (self.isPlaying)
    {
        self.isPlaying = NO;
        [self.playButton setImage:[UIImage imageNamed:@"PlayMusic"] forState:UIControlStateNormal];
    }
    else
    {
        self.isPlaying = YES;
        [self.playButton setImage:[UIImage imageNamed:@"PauseMusic"] forState:UIControlStateNormal];
    }
    
    if ([self.delegate respondsToSelector:@selector(selectedPlayIndex:isPlayingStatus:)])
    {
        [self.delegate selectedPlayIndex:self.nIndex isPlayingStatus:self.isPlaying];
    }
}

- (void)setPlaybuttonStatus:(BOOL) playing
{
    self.isPlaying = playing;
    
    if (self.isPlaying)
    {
        [self.playButton setImage:[UIImage imageNamed:@"PauseMusic"] forState:UIControlStateNormal];
    }
    else
    {
        [self.playButton setImage:[UIImage imageNamed:@"PlayMusic"] forState:UIControlStateNormal];
    }
}


- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing {
    [super setEditing:editing];
    
    if (editing) {
        self.detailTextLabel.hidden = YES;
        self.playButton.hidden = YES;
    } else {
        self.detailTextLabel.hidden = NO;
        self.playButton.hidden = NO;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if (editing) {
        self.detailTextLabel.hidden = YES;
        self.playButton.hidden = YES;
    } else {
        self.detailTextLabel.hidden = NO;
        self.playButton.hidden = NO;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [textField performSelector:@selector(selectAll:) withObject:textField afterDelay:0.0f];

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""]) {
        [textField setText:self.originalName];
        NSString *errorMessage = [NSString stringWithFormat:NSLocalizedString(@"A music filename can not be empty! Please try again.", nil), textField.text];
        [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:errorMessage okHandler:nil];
        return;
    }
    
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:@"Music Library"];
    folderPath = [folderPath stringByAppendingPathComponent:self.folderName];

    NSString *oldName = [folderPath stringByAppendingPathComponent:self.originalName];
    NSString *fileExtension = oldName.pathExtension;
    
    NSString *changeName = [folderPath stringByAppendingPathComponent:textField.text];
    NSString *newExtension = changeName.pathExtension;
    if ([fileExtension isEqualToString:newExtension] == NO) {
        changeName = [NSString stringWithFormat:@"%@.%@", changeName, fileExtension];
    }
    
    if (rename([oldName fileSystemRepresentation], [changeName fileSystemRepresentation]) == -1)
    {
        [textField setText:self.originalName];
        
        NSString *errorMessage = [NSString stringWithFormat:NSLocalizedString(@"A music \"%@\" is exist already! Please set another new name.", nil), textField.text];
        [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:errorMessage okHandler:nil];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(changedMusicName)])
        {
            [self.delegate changedMusicName];
        }
    }

    //[self.titleLabel setText:textField.text];
    self.originalName = changeName.lastPathComponent;
    self.nameTextField.text = self.originalName;
}

@end
