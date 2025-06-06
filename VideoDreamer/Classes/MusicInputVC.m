//
//  MusicInputVC
//  VideoFrame
//
//  Created by APPLE on 11/14/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import "MusicInputVC.h"
#import "MusicDownload.h"
#import "Definition.h"
#import "ProjectManager.h"
#import "SHKActivityIndicator.h"
#import "Music.h"

@interface MusicInputVC ()< UITableViewDelegate, NSObject, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
{
    IBOutlet UIButton *backButton;
    
    BOOL isPhotoTake;
    BOOL isReplace;

    NSMutableArray *personArray;
}

@end

@implementation MusicInputVC

@synthesize musicDownload = musicDownload;
@synthesize music;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.musicDownload = (MusicDownload*)self.navigationController;
    
    self.nameTextField.delegate = self;
    self.urlTextField.delegate = self;
    self.loginTextField.delegate = self;
    self.notesTextField.delegate = self;
    
    if (@available(iOS 13.0, *)) {
        [backButton setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
    } else {
        [backButton setImage:nil forState:UIControlStateNormal];
    }
    
    //Project Manager
    self.projectManager = [[ProjectManager alloc] init];
    
    gstrCurrentProjectName = self.projectManager.projectName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *editRowIndex= [userDefaults valueForKey:@"editSite"];
    
    if (editRowIndex.integerValue != 0) {
     
        NSMutableArray * musicSites = [userDefaults objectForKey:@"allSites"];
        
        NSMutableArray *sitesArray = [NSMutableArray arrayWithCapacity:musicSites.count];
        
        int j;
        NSError *error;
        for (j = 0; j < musicSites.count; j++) {
            Music *musicDecodedObject = [NSKeyedUnarchiver unarchivedObjectOfClass:[Music class] fromData:musicSites[j] error:&error];
            [sitesArray addObject:musicDecodedObject];
        }
        
        long i = 0;
        for (Music *musicObject in sitesArray) {
            
            i = i + 1;
            if (i == editRowIndex.integerValue) {
                
                _nameTextField.text = musicObject.name;
                _urlTextField.text = musicObject.url;
                _loginTextField.text = musicObject.login;
                _notesTextField.text = musicObject.notes;
            }
        }
    }
    if (editRowIndex.integerValue == 0 && editRowIndex != nil) {
        
        NSMutableArray * musicSites= [userDefaults objectForKey:@"defaultSite"];
        
        if (musicSites != nil) {
            NSMutableArray *sitesArray = [NSMutableArray arrayWithCapacity:musicSites.count];
            
            int j;
            NSError *error;
            for (j=0; j < musicSites.count; j++) {
                NSData *musicDecodedObject = [NSKeyedUnarchiver unarchivedObjectOfClass:[Music class] fromData:musicSites[j] error:&error];
                [sitesArray addObject:musicDecodedObject];
            }
            
            for (Music *musicObject in sitesArray) {
                _nameTextField.text = musicObject.name;
                _urlTextField.text = musicObject.url;
                _loginTextField.text = musicObject.login;
                _notesTextField.text = musicObject.notes;
            }
        } else {
            NSString *urlString = @"https://www.youtube.com/audiolibrary/music"; // https://soundcloud.com/youtubeaudiolibrary
            _urlTextField.text = urlString;

            _nameTextField.text =  @"YouTube";
            _loginTextField.text = @"";
            _notesTextField.text = @"";
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)actionSaveButton:(id)sender {
    
    NSString *name  = [_nameTextField text];
    NSString *url   = [_urlTextField text];
    NSString *login = [_loginTextField text];
    NSString *notes = [_notesTextField text];
    
    Music *musicSite = [[Music alloc] init];
    musicSite.name = name;
    musicSite.url = url;
    musicSite.login = login;
    musicSite.notes = notes;
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *editRowIndex = [userDefaults valueForKey:@"editSite"];
    
    if (editRowIndex.integerValue != 0) {
        NSMutableArray * musicSites= [userDefaults objectForKey:@"allSites"];
        
        NSMutableArray *sitesArray = [NSMutableArray arrayWithCapacity:musicSites.count];
        NSError *error;
        for (NSData *musicObject in musicSites) {
            NSData *musicDecodedObject = [NSKeyedUnarchiver unarchivedObjectOfClass:[Music class] fromData:musicObject error:&error];
            [sitesArray addObject:musicDecodedObject];
        }
        
        long i = 0;
        for (Music *musicObject in sitesArray) {
            if (i == editRowIndex.integerValue-1) {
                
                musicObject.name = musicSite.name;
                musicObject.url = musicSite.url;
                musicObject.login = musicSite.login;
                musicObject.notes = musicSite.notes;
                
                [sitesArray replaceObjectAtIndex:i withObject:musicObject];
                
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:sitesArray.count];
                NSError *error;
                for (Music *musicObject in sitesArray) {
                    NSData *musicEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:musicObject requiringSecureCoding:NO error:&error];
                    [tempArray addObject:musicEncodedObject];
                }
                
                [userDefaults setValue:tempArray forKey:@"allSites"];
                
                [userDefaults setValue:nil forKey:@"tempSites"];
                
                [self saveMusic];
                
                return;
            }
            
            i = i + 1;
        }
    }
    if (editRowIndex.integerValue == 0 && editRowIndex != nil) {
        NSMutableArray * musicSites= [userDefaults objectForKey:@"defaultSite"];
        
        if (musicSites != nil) {
            NSError *error;
            NSMutableArray *sitesArray = [NSMutableArray arrayWithCapacity:musicSites.count];
            for (NSData *musicObject in musicSites) {
                NSData *musicDecodedObject = [NSKeyedUnarchiver unarchivedObjectOfClass:[Music class] fromData:musicObject error:&error];
                [sitesArray addObject:musicDecodedObject];
            }
         
            long i = 0;
            for (Music *musicObject in sitesArray) {
                
                musicObject.name = musicSite.name;
                musicObject.url = musicSite.url;
                musicObject.login = musicSite.login;
                musicObject.notes = musicSite.notes;
                
                [sitesArray replaceObjectAtIndex:i withObject:musicObject];
                
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:sitesArray.count];
                NSError *error;
                for (Music *musicObject in sitesArray) {
                    NSData *musicEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:musicObject requiringSecureCoding:NO error:&error];
                    [tempArray addObject:musicEncodedObject];
                }
                
                [userDefaults setValue:tempArray forKey:@"defaultSite"];
                
                [userDefaults setValue:nil forKey:@"tempSites"];
                
                [self saveMusic];
            }
        }
        if (musicSites == nil) {

            NSMutableArray *sitesArray = [NSMutableArray arrayWithCapacity:100];
            Music *musicObject = [[Music alloc] init];
                
            musicObject.name = musicSite.name;
            musicObject.url = musicSite.url;
            musicObject.login = musicSite.login;
            musicObject.notes = musicSite.notes;
            
            [sitesArray addObject:musicObject];
                
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:sitesArray.count];
            NSError *error;
            for (Music *musicObject in sitesArray) {
                NSData *musicEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:musicObject requiringSecureCoding:NO error:&error];
                [tempArray addObject:musicEncodedObject];
            }
            
            [userDefaults setValue:tempArray forKey:@"defaultSite"];
            
            [userDefaults setValue:nil forKey:@"tempSites"];
            
            [self saveMusic];
        }
    } else {
        NSMutableArray *musicArray = [[NSMutableArray alloc] initWithCapacity:10];
        
        [musicArray addObject:musicSite];
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:musicArray.count];
        NSError *error;
        for (Music *musicObject in musicArray) {
            NSData *musicEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:musicObject requiringSecureCoding:NO error:&error];
            [tempArray addObject:musicEncodedObject];
        }
        
        [userDefaults setValue:tempArray forKey:@"tempSites"];
        [self saveMusic];
    }
}


-(void) saveMusic
{
    [self showAlertViewController:NSLocalizedString(@"Video Dreamer", nil) message:NSLocalizedString(@"Music Information is saved successfully!", nil) okHandler:nil];
}

-(void) deleteMusicAlert
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Video Dreamer", nil) message:NSLocalizedString(@"Would you like to delete this music information?", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self deleteMusic];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        return;
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)actionListButton:(id)sender {
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)actionDeleteButton:(id)sender {
    
    [self deleteMusicAlert];
}

-(void) deleteMusic
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger editRowIndex = [userDefaults integerForKey:@"editSite"];
    
    if (editRowIndex != 0) {
        
        NSMutableArray * musicSites= [userDefaults objectForKey:@"allSites"];
        
        NSMutableArray *sitesArray = [NSMutableArray arrayWithCapacity:musicSites.count];
        NSError *error;
        for (NSData *musicObject in musicSites) {
            NSData *musicDecodedObject = [NSKeyedUnarchiver unarchivedObjectOfClass:[Music class] fromData:musicObject error:&error];
            [sitesArray addObject:musicDecodedObject];
        }
        
        long i = 0;
        for (Music *musicObject in sitesArray) {
            if (i == (long)editRowIndex-1) {

                NSLog(@"musicObject.url_________: %@", musicObject.url);
                
                [sitesArray removeObjectAtIndex:i];
                
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:sitesArray.count];
                for (Music *musicObject in sitesArray) {
                    NSData *musicEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:musicObject requiringSecureCoding:NO error:&error];
                    [tempArray addObject:musicEncodedObject];
                }
                
                [userDefaults setValue:tempArray forKey:@"allSites"];
                [userDefaults setInteger:editRowIndex forKey:@"deleteSite"];
                [userDefaults setValue:nil forKey:@"tempSites"];
                
                [self dismissViewControllerAnimated:true completion:nil];
                
                return;
            }
            
            i = i + 1;
        }
    }
}

@end
