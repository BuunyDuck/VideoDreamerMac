//
//  LaunchVC.m
//  RandomMusicPlayer
//
//  Created by APPLE on 11/27/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import "TermsVC.h"

@interface TermsVC ()

@end

@implementation TermsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    if (@available(iOS 13.0, *)) {
        [self.backButton setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
    } else {
        [self.backButton setImage:nil forState:UIControlStateNormal];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //    if([segue.identifier isEqualToString:@"GoToMusicVC"])
    
}

- (IBAction)actionBack:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
