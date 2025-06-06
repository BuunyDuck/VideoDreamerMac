//
//  MusicDownloadWebVC.m
//  VideoFrame
//
//  Created by APPLE on 11/14/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import "MusicDownloadVC.h"
#import "MusicDownload.h"
#import "TableCell.h"
#import "MusicInputVC.h"
#import "SHKActivityIndicator.h"
#import "Music.h"
#import "MusicDownloadController.h"
#import "VideoDreamer-Swift.h"

@interface MusicDownloadVC() <MusicDownloadControllerDelegate>
{
    IBOutlet UIBarButtonItem *cancelButton;
}

@end

@implementation MusicDownloadVC

@synthesize musicDownload = musicDownload;
@synthesize music;
@synthesize musicInputVC = musicInputVC;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *normalButtonItemAttributes = @{NSFontAttributeName:[UIFont fontWithName:MYRIADPRO size:16.0],
                                                 NSForegroundColorAttributeName:[UIColor blackColor]};
    NSDictionary *highlightButtonItemAttributes = @{NSFontAttributeName:[UIFont fontWithName:MYRIADPRO size:16.0],
                                                    NSForegroundColorAttributeName:[UIColor darkGrayColor]};
    [cancelButton setTitleTextAttributes:normalButtonItemAttributes forState:UIControlStateNormal];
    [cancelButton setTitleTextAttributes:highlightButtonItemAttributes forState:UIControlStateHighlighted];
    
    self.musicDownload = (MusicDownload *)self.navigationController;
    
    tableView.delegate = self;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *musicSites;
    if ([userDefaults objectForKey:@"allSites"] != nil) {
        musicSites = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"allSites"]];
    } else {
        musicSites = [NSMutableArray array];
    }
    
    if ([userDefaults boolForKey:APP_WEBSITES_INITIALIZED] == NO) {
        NSString *urlString = @"https://www.youtube.com/audiolibrary/music"; // https://soundcloud.com/youtubeaudiolibrary
        Music *youtubeMusic = [[Music alloc] initWithName:@"Youtube" url:urlString];
        musicList = [[NSMutableArray alloc] initWithObjects:youtubeMusic, nil];
        
        [userDefaults setBool:YES forKey:APP_WEBSITES_INITIALIZED];
        NSURL *downloadURL = [[NSBundle mainBundle] URLForResource:@"DownloadLists" withExtension:@"plist"];
        NSDictionary *root = [NSDictionary dictionaryWithContentsOfURL:downloadURL];
        NSArray *downloadList = root[@"DownloadLists"];
        NSError *error = nil;
        for (NSDictionary *dictionary in downloadList) {
            Music *music = [[Music alloc] initWithName:dictionary[@"Title"] url:dictionary[@"Site"] login:dictionary[@"Login"] notes:dictionary[@"Notes"] image:dictionary[@"Image"]];
            NSData *musicEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:music requiringSecureCoding:NO error:&error];
            [musicSites addObject:musicEncodedObject];
        }
        [userDefaults setObject:musicSites forKey:@"allSites"];
    } else {
        musicList = [[NSMutableArray alloc] init];
    }

    NSMutableArray *sitesArray = [NSMutableArray arrayWithCapacity:musicSites.count];
    NSError *error;
    for (NSData *musicObject in musicSites) {
        NSData *musicDecodedObject = [NSKeyedUnarchiver unarchivedObjectOfClass:[Music class] fromData:musicObject error:&error];
        [sitesArray addObject:musicDecodedObject];
    }

    for (Music *musicObject in sitesArray) {

        [musicList addObject: musicObject];

        NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithObject:[NSIndexPath indexPathForRow:musicList.count - 1 inSection:0]];
        [tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
    }
    
    NSMutableArray *defaultSite = [userDefaults objectForKey:@"defaultSite"];
    
    NSMutableArray *defaultArray = [NSMutableArray arrayWithCapacity:defaultSite.count];
    for (NSData *musicObject in defaultSite) {
        NSData *musicDecodedObject = [NSKeyedUnarchiver unarchivedObjectOfClass:[Music class] fromData:musicObject error:&error];
        [defaultArray addObject:musicDecodedObject];
    }
    
    for (Music *musicObject in defaultArray) {
        
        [musicList replaceObjectAtIndex:0 withObject:musicObject];
        
        NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        [tableView reloadRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadSitesList];
}

- (void)loadSitesList {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tempArray= [userDefaults objectForKey:@"tempSites"];
    NSNumber *editRowIndex = [userDefaults valueForKey:@"editSite"];
    
    NSInteger deletedRowIndex = [userDefaults integerForKey:@"deleteSite"];
    if (tempArray == nil && editRowIndex.integerValue != 0 && editRowIndex != nil) {
        
        NSMutableArray * musicSites= [userDefaults objectForKey:@"allSites"];
        NSMutableArray *sitesArray = [NSMutableArray arrayWithCapacity:musicSites.count];
        NSError *error;
        for (NSData *musicObject in musicSites) {
            NSData *musicDecodedObject = [NSKeyedUnarchiver unarchivedObjectOfClass:[Music class] fromData:musicObject error:&error];
            [sitesArray addObject:musicDecodedObject];
        }
        
        long i = 0;
        for (Music *musicObject in sitesArray) {
            if (i == editRowIndex.integerValue - 1) {
                [musicList replaceObjectAtIndex:i + 1 withObject:musicObject];
                
                NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithObject:[NSIndexPath indexPathForRow:i + 1 inSection:0]];
                [tableView reloadRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
            }
            
            i = i + 1;
        }
        
        if (deletedRowIndex != 0) {
            
            [musicList removeObjectAtIndex:deletedRowIndex];
            [tableView reloadData];
            
            [userDefaults setValue:nil forKey:@"deleteSite"];
        }
        
        [userDefaults setValue:nil forKey:@"editSite"];
    }
    
    if (tempArray == nil && editRowIndex.integerValue == 0 && editRowIndex != nil)
    {
        NSMutableArray * musicSites= [userDefaults objectForKey:@"defaultSite"];
        NSMutableArray *sitesArray = [NSMutableArray arrayWithCapacity:musicSites.count];
        NSError *error;
        for (NSData *musicObject in musicSites) {
            NSData *musicDecodedObject = [NSKeyedUnarchiver unarchivedObjectOfClass:[Music class] fromData:musicObject error:&error];
            [sitesArray addObject:musicDecodedObject];
        }
        
        for (Music *musicObject in sitesArray) {
            
            [musicList replaceObjectAtIndex:0 withObject:musicObject];
            
            NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
            [tableView reloadRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        }
        
        [userDefaults setValue:nil forKey:@"editSite"];
    }
    
    if (tempArray != nil) {
        NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:tempArray.count];
        NSError *error;
        for (NSData *musicObject in tempArray) {
            NSData *musicDecodedObject = [NSKeyedUnarchiver unarchivedObjectOfClass:[Music class] fromData:musicObject error:&error];
            [archiveArray addObject:musicDecodedObject];
        }
        
        Music * musicSite = (Music *) archiveArray[0];
        
        [musicList addObject: musicSite];
        
        NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithObject:[NSIndexPath indexPathForRow:musicList.count - 1 inSection:0]];
        [tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        
        [userDefaults setObject:nil forKey:@"tempSites"];
        
        NSMutableArray * musicSites = [userDefaults objectForKey:@"allSites"];
        
        NSMutableArray *sitesArray = [NSMutableArray arrayWithCapacity:musicSites.count];
        for (NSData *musicObject in musicSites) {
            NSData *musicDecodedObject = [NSKeyedUnarchiver unarchivedObjectOfClass:[Music class] fromData:musicObject error:&error];
            [sitesArray addObject:musicDecodedObject];
        }
        
        [sitesArray addObject: musicSite];
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:sitesArray.count];
        for (Music *musicObject in sitesArray) {
            NSData *musicEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:musicObject requiringSecureCoding:NO error:&error];
            [tempArray addObject:musicEncodedObject];
        }
        
        [userDefaults setValue:tempArray forKey:@"allSites"];
    }
}

#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return musicList.count + 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"TableCell";
    
    TableCell *cell = (TableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    NSArray *nib;
    
    if (cell == nil)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            nib = [[NSBundle mainBundle] loadNibNamed:@"TableCell" owner:self options:nil];
        else
            nib = [[NSBundle mainBundle] loadNibNamed:@"TableCell_iPad" owner:self options:nil];
        
        cell = [nib objectAtIndex:0];
        cell.delegate = self;
    }
    
    [cell reloadCell:indexPath.row];
    
    if (indexPath.row == 0) {
        Music *music = [[Music alloc] initWithName:@"WiFi Download from PC" url:@""];
        cell.nameCellLabel.text = music.name;
        cell.cellEditButton.hidden = YES;
    } else if (indexPath.row == 1) {
        Music *music = [[Music alloc] initWithName:@"MyOS™Radio Select Song Download" url:@""];
        cell.nameCellLabel.text = music.name;
        cell.cellEditButton.hidden = YES;
    } else {
        Music *music = musicList[indexPath.row - 2];
        cell.urlCellLabel.text = music.url;
        cell.nameCellLabel.text = music.name;
        cell.cellEditButton.hidden = NO;
    }
    
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        NSString *nibName = @"WiFiTransferViewController";
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            nibName = @"WiFiTransferViewController_iPad";
        }
        WiFiTransferViewController *controller = [[WiFiTransferViewController alloc] initWithNibName:nibName bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.row == 1) {
        NSURL *URL = [NSURL URLWithString: @"https://www.montanasky.net/myossongs/index.tpl"];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setURL:URL forKey:@"viewSite"];
        
        if ([self.musicDownload.musicDownloadDelegate respondsToSelector:@selector(musicSiteDidSelected:)])
        {
            [self.musicDownload.musicDownloadDelegate musicSiteDidSelected:self.musicDownload];
        }
    } else {
        Music *music = [musicList objectAtIndex:indexPath.row - 2];
        NSURL *URL = [NSURL URLWithString: music.url];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setURL:URL forKey:@"viewSite"];
        
        if ([self.musicDownload.musicDownloadDelegate respondsToSelector:@selector(musicSiteDidSelected:)])
        {
            [self.musicDownload.musicDownloadDelegate musicSiteDidSelected:self.musicDownload];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return 44.0;
    } else {
        return 64.0;
    }
}

- (IBAction)actionCancel:(id)sender
{
    if ([self.musicDownload.musicDownloadDelegate respondsToSelector:@selector(musicDownloadDidCancel:)])
    {
        [self.musicDownload.musicDownloadDelegate musicDownloadDidCancel:self.musicDownload];
    }
}

- (void)didEditSite:(NSInteger) index
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:index forKey:@"editSite"];
    
    if (!musicInputVC)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MusicDownload" bundle:nil];
            musicInputVC = [sb instantiateViewControllerWithIdentifier:@"MusicInputVC"];
        }
        else
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MusicDownload_iPad" bundle:nil];
            musicInputVC = [sb instantiateViewControllerWithIdentifier:@"MusicInputVC"];
        }
    }
    
    musicInputVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:musicInputVC animated:YES completion:nil];
}

- (void)editButtonDidSelected:(NSInteger) index
{
    [self didEditSite:index];
}

@end
