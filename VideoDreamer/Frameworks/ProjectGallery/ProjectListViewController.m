//
//  ProjectListViewController.m
//  VideoFrame
//
//  Created by YinjingLi on 1/14/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import "ProjectListViewController.h"
#import "ProjectGalleryPickerController.h"
#import "ProjectCell.h"
#import "Definition.h"
#import "SHKActivityIndicator.h"
#import "MyCloudDocument.h"
#import "SSZipArchive.h"
#import "TTOpenInAppActivity.h"

@interface ProjectListViewController ()

@end

@implementation ProjectListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    //  navigation controller
    self.projectGalleryPickerController = (ProjectGalleryPickerController*)self.navigationController;
    self.isBackup = self.projectGalleryPickerController.isBackup;
    self.isSharing = self.projectGalleryPickerController.isSharing;

    //  specialist white background
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageView setImage:[UIImage imageNamed:@"specialistEditBg"]];
    self.projectListTableView.backgroundView = imageView;
    
    //  cancel button
    [self.cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:16.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:16.0f], NSFontAttributeName, [UIColor darkGrayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateHighlighted];

    //  select all button
    self.selectAllButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select All", nil) style:UIBarButtonItemStylePlain target:self action:@selector(actionSelectAll:)];
    [self.selectAllButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:16.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.selectAllButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:16.0f], NSFontAttributeName, [UIColor darkGrayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateHighlighted];

    if (self.isSharing) // Share a Saved Project
    {
        //  share a saved project button
        self.shareProjectButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share", nil) style:UIBarButtonItemStylePlain target:self action:@selector(actionShareSavedProject:)];
        [self.shareProjectButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:16.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        [self.shareProjectButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:16.0f], NSFontAttributeName, [UIColor darkGrayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateHighlighted];
        
        self.navigationItem.rightBarButtonItems = @[self.shareProjectButton, self.selectAllButton];

        [self fetchProjects];
    }
    else    // Backup a Saved Project to iCloud / Restore a Project from iCloud
    {
        //  backup restore button
        self.backupRestoreButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Backup", nil) style:UIBarButtonItemStylePlain target:self action:@selector(actionBackupRestore:)];
        [self.backupRestoreButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:16.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        [self.backupRestoreButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:16.0f], NSFontAttributeName, [UIColor darkGrayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateHighlighted];
        
        self.navigationItem.rightBarButtonItems = @[self.backupRestoreButton, self.selectAllButton];

        if (self.isBackup)  //backup to iCloud
        {
            [self.backupRestoreButton setTitle:NSLocalizedString(@"Backup", nil)];
            
            [self fetchProjects];
        }
        else    //restore from iCloud
        {
            [self.backupRestoreButton setTitle:NSLocalizedString(@"Restore", nil)];
            
            [self loadSavedProjectsFromICloud];
        }
    }
    
    
    [self.projectListTableView reloadData];
    
    isSelectAll = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 
#pragma mark - fetch a Saved Project on Local directory

-(void) fetchProjects
{
    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;
    self.projectNamesArray = [[NSMutableArray alloc] init];

    NSError *error;
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    
    if (filesArray.count > 0)
    {
        NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
        
        for(NSString* file in filesArray)
        {
            error = nil;
            
            NSString* filePath = [documentsPath stringByAppendingPathComponent:file];
            NSDictionary* properties = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:filePath
                                        error:&error];
            NSDate* modDate = [properties objectForKey:NSFileModificationDate];
            
            if(error == nil)
            {
                [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                               file, @"path",
                                               modDate, @"lastModDate",
                                               nil]];
            }
        }
        
        NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                                ^(id path1, id path2)
                                {
                                    NSComparisonResult comp = [[path2 objectForKey:@"lastModDate"] compare:
                                                               [path1 objectForKey:@"lastModDate"]];
                                    if (comp == NSOrderedDescending)
                                        comp = NSOrderedAscending;
                                    else if(comp == NSOrderedAscending)
                                        comp = NSOrderedDescending;
                                    
                                    return comp;
                                }];
        
        for (int i = 0; i < sortedFiles.count; i++)
        {
            NSDictionary* dict = [sortedFiles objectAtIndex:i];
            
            NSString* projectPath = [documentsPath stringByAppendingPathComponent:[dict objectForKey:@"path"]];
            NSString* filePath = [projectPath stringByAppendingPathComponent:@"screenshot.png"];
            
            if([localFileManager fileExistsAtPath:filePath])
                [self.projectNamesArray addObject:[dict objectForKey:@"path"]];
        }
    }
    
    
    [self.projectThumbnailArray removeAllObjects];
    self.projectThumbnailArray = nil;
    self.projectThumbnailArray = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i < self.projectNamesArray.count; i++)
    {
        NSString* projectName = [self.projectNamesArray objectAtIndex:i];
        NSString* projectPath = [documentsPath stringByAppendingPathComponent:projectName];
        NSString* filePath = [projectPath stringByAppendingPathComponent:@"screenshot.png"];
        
        UIImage* screenshotImage = [UIImage imageWithContentsOfFile:filePath];
        
        [self.projectThumbnailArray addObject:screenshotImage];
    }

    
    [self.projectSelectionFlagArray removeAllObjects];
    self.projectSelectionFlagArray = nil;
    self.projectSelectionFlagArray = [[NSMutableArray alloc] init];

    for (int i = 0; i < self.projectNamesArray.count; i++)
    {
        [self.projectSelectionFlagArray addObject:[NSNumber numberWithBool:NO]];
    }
}

#pragma mark - 
#pragma mark - Load a Saved Projects from iCloud

-(void)loadSavedProjectsFromICloud
{
    [[SHKActivityIndicator currentIndicator] displayActivity:(@"Load projects from iCloud...") isLock:YES];

    self.query = [[NSMetadataQuery alloc] init];
    [self.query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
    NSPredicate *pred = [NSPredicate predicateWithFormat: @"%K like '*.zip'", NSMetadataItemFSNameKey];
    [self.query setPredicate:pred];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidFinishGathering:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:self.query];
    
    [self.query startQuery];
}

- (void)queryDidFinishGathering:(NSNotification *)notification
{
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];
    
    [self loadData:query];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:query];
    
    self.query = nil;
}

- (void)loadData:(NSMetadataQuery *)query
{
    NSFileManager *localFileManager = [NSFileManager defaultManager];

    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;
    self.projectNamesArray = [[NSMutableArray alloc] init];

    [self.projectThumbnailArray removeAllObjects];
    self.projectThumbnailArray = nil;
    self.projectThumbnailArray = [[NSMutableArray alloc] init];

    [self.projectSelectionFlagArray removeAllObjects];
    self.projectSelectionFlagArray = nil;
    self.projectSelectionFlagArray = [[NSMutableArray alloc] init];

    
    selectedProjectCount = (int)[[query results] count];
    _saveCount = 0;
    
    if (selectedProjectCount == 0)
    {
        [[SHKActivityIndicator currentIndicator] hide];
    }
    
    for (NSMetadataItem *item in [query results])
    {
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        
        NSString* projectPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[url lastPathComponent]];
        projectPath = [projectPath stringByReplacingOccurrencesOfString:@".zip" withString:@""];

        if ([localFileManager fileExistsAtPath:projectPath])
        {
            [self.projectNamesArray addObject:[projectPath lastPathComponent]];

            NSString* filePath = [projectPath stringByAppendingPathComponent:@"screenshot.png"];
            UIImage* screenshotImage = [UIImage imageWithContentsOfFile:filePath];
            [self.projectThumbnailArray addObject:screenshotImage];

            _saveCount++;
            
            if (_saveCount == selectedProjectCount)
            {
                for (int i = 0; i < self.projectNamesArray.count; i++)
                {
                    [self.projectSelectionFlagArray addObject:[NSNumber numberWithBool:NO]];
                }
                
                [self.projectListTableView reloadData];
                
                [[SHKActivityIndicator currentIndicator] hide];
            }
        }
        else
        {
            MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:url];
            
            int _selectedProjectCount = selectedProjectCount;
            [mydoc openWithCompletionHandler:^(BOOL success) {
                
                if (success)
                {
                    //download zip file to temp folder
                    NSData* zipFileData = mydoc.dataContent;
                    
                    NSString* zipFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[url lastPathComponent]];
                    unlink([zipFilePath UTF8String]);
                    
                    [zipFileData writeToFile:zipFilePath atomically:YES];
                    
                    [mydoc closeWithCompletionHandler:^(BOOL success) {
                        
                    }];
                    
                    
                    //unzip
                    NSString* unzipFolderPath = [zipFilePath stringByReplacingOccurrencesOfString:@".zip" withString:@""];

                    @autoreleasepool
                    {
                        [SSZipArchive unzipFileAtPath:zipFilePath toDestination:unzipFolderPath];
                    }
                    
                    
                    [self.projectNamesArray addObject:[unzipFolderPath lastPathComponent]];
                    
                    NSString* filePath = [unzipFolderPath stringByAppendingPathComponent:@"screenshot.png"];
                    UIImage* screenshotImage = [UIImage imageWithContentsOfFile:filePath];
                    [self.projectThumbnailArray addObject:screenshotImage];
                    
                    unlink([zipFilePath UTF8String]);
                    
                    self.saveCount++;
                    
                    if (self.saveCount == _selectedProjectCount)
                    {
                        for (int i = 0; i < self.projectNamesArray.count; i++)
                        {
                            [self.projectSelectionFlagArray addObject:[NSNumber numberWithBool:NO]];
                        }
                        
                        [self.projectListTableView reloadData];
                        
                        [[SHKActivityIndicator currentIndicator] hide];
                    }
                }
                
            }];
        }
    }
}

#pragma mark -
#pragma mark - action Cancel

-(IBAction)actionCancel:(id)sender
{
    if ([self.projectGalleryPickerController.projectGalleryPickerDelegate respondsToSelector:@selector(projectGalleryPickerControllerDidCancel:)])
    {
        [self.projectGalleryPickerController.projectGalleryPickerDelegate projectGalleryPickerControllerDidCancel:self.projectGalleryPickerController];
    }
}


#pragma mark -
#pragma mark - action Select/Deselect All

-(void)actionSelectAll:(id)sender
{
    isSelectAll = !isSelectAll;
    
    if (isSelectAll)
    {
        [self.selectAllButton setTitle:NSLocalizedString(@"Deselect All", nil)];
        
        for (int i = 0; i < self.projectSelectionFlagArray.count; i++)
        {
            [self.projectSelectionFlagArray replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
        }
    }
    else
    {
        [self.selectAllButton setTitle:NSLocalizedString(@"Select All", nil)];

        for (int i = 0; i < self.projectSelectionFlagArray.count; i++)
        {
            [self.projectSelectionFlagArray replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    [self.projectListTableView reloadData];
}


#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.projectNamesArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"ProjectCell";
    
    if (self.projectNamesArray.count > 0)
    {
        ProjectCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.projectNameLabel.text = [self.projectNamesArray objectAtIndex:indexPath.row];
        cell.projectThumbImageView.image = [self.projectThumbnailArray objectAtIndex:indexPath.row];
        
        BOOL isSelected = [[self.projectSelectionFlagArray objectAtIndex:indexPath.row] boolValue];
        cell.isSelected = isSelected;
        [cell didSelected:isSelected];
        
        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL isSelected = [[self.projectSelectionFlagArray objectAtIndex:indexPath.row] boolValue];

    [self.projectSelectionFlagArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:!isSelected]];
}


#pragma mark -
#pragma mark - action Backup / Restore

-(void)actionBackupRestore:(id)sender
{
    selectedProjectCount = 0;
    
    if (self.projectSelectionFlagArray.count == 0)
    {
        return;
    }
    
    for (int i = 0; i < self.projectSelectionFlagArray.count; i++)
    {
        BOOL isSelected = [[self.projectSelectionFlagArray objectAtIndex:i] boolValue];

        if (isSelected)
        {
            selectedProjectCount++;
        }
    }
    
    if (selectedProjectCount > 0)
    {
        if (self.isBackup)
        {
            NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
            
            if (ubiq)
            {
                [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Backup to iCloud...", nil)) isLock:YES];
                
                [self performSelector:@selector(saveProjectsToICloud) withObject:nil afterDelay:0.2f];   //save data to iCloud
            }
            else
            {
                [self showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please login to iCloud first!", nil) okHandler:nil];
            }
        }
        else
        {
            NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
            
            if (ubiq)
            {
                [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Restore from iCloud...", nil)) isLock:YES];
                
                [self performSelector:@selector(restoreProjectsFromICloud) withObject:nil afterDelay:0.2f];   //restore data from iCloud
            }
            else
            {
                [self showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please login to iCloud first!", nil) okHandler:nil];
            }
        }
    }
}


#pragma mark - 
#pragma mark - Save project to iCloud

-(void)saveProjectsToICloud
{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    _saveCount = 0;
    
    for (int i = 0; i < self.projectSelectionFlagArray.count; i++)
    {
        BOOL isSelected = [[self.projectSelectionFlagArray objectAtIndex:i] boolValue];

        if (isSelected)
        {
            NSString* projectName = [self.projectNamesArray objectAtIndex:i];
            NSString* projectPath = [documentsPath stringByAppendingPathComponent:projectName];

            //zip project
            NSString* zipFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", projectName]];
            unlink([zipFilePath UTF8String]);
            
            @autoreleasepool
            {
                [SSZipArchive createZipFileAtPath:zipFilePath withContentsOfDirectory:projectPath];
            }
            
            //Save zip file to iCloud
            NSURL* zipUrl = [NSURL fileURLWithPath:zipFilePath];

            NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
            NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:[zipUrl lastPathComponent]];
            
            MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
            NSData *data = [NSData dataWithContentsOfFile:zipFilePath];
            mydoc.dataContent = data;
            
            int _selectedProjectCount = selectedProjectCount;
            [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                if (success)
                {

                }
                else
                {
                    NSLog(@"Saving failed zip to icloud");
                }
                 
                unlink([zipFilePath UTF8String]);
                
                self.saveCount++;
                
                if (self.saveCount == _selectedProjectCount)
                {
                    [[SHKActivityIndicator currentIndicator] hide];
                    
                    if ([self.projectGalleryPickerController.projectGalleryPickerDelegate respondsToSelector:@selector(projectGalleryPickerControllerDidCancel:)])
                    {
                        [self.projectGalleryPickerController.projectGalleryPickerDelegate projectGalleryPickerControllerDidCancel:self.projectGalleryPickerController];
                    }
                    
                    NSFileManager* localFileManager = [NSFileManager defaultManager];
                    NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
                    NSString* plistFolderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];

                    NSString* lastUpdatePlistFileName = [plistFolderPath stringByAppendingPathComponent:@"LastUpdate.plist"];
                     
                    BOOL isDirectory = NO;
                    BOOL exist = [localFileManager fileExistsAtPath:lastUpdatePlistFileName isDirectory:&isDirectory];
                     
                    NSMutableDictionary* lastUpdatePlistDict = nil;
                    
                    if (!exist)
                    {
                        [localFileManager createFileAtPath:lastUpdatePlistFileName contents:nil attributes:nil];
                        
                        lastUpdatePlistDict = [NSMutableDictionary dictionary];
                    }
                    else
                    {
                        lastUpdatePlistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:lastUpdatePlistFileName];
                    }
                    
                    NSDate* currentDate = [NSDate date];
                    [lastUpdatePlistDict setObject:currentDate forKey:@"LastUpdatedDate"];
                    [lastUpdatePlistDict writeToFile:lastUpdatePlistFileName atomically:YES];
                 }
            }];
        }
    }
}


#pragma mark -
#pragma mark - Restore project from iCloud

-(void)restoreProjectsFromICloud
{
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    _saveCount = 0;
    
    for (int i = 0; i < self.projectSelectionFlagArray.count; i++)
    {
        BOOL isSelected = [[self.projectSelectionFlagArray objectAtIndex:i] boolValue];
        
        if (isSelected)
        {
            NSString* projectName = [self.projectNamesArray objectAtIndex:i];
            NSString* projectPath = [NSTemporaryDirectory() stringByAppendingPathComponent:projectName];
            NSString* savePath = [documentsPath stringByAppendingPathComponent:projectName];

            NSError* error = nil;

            if ([localFileManager fileExistsAtPath:savePath])
            {
                [localFileManager removeItemAtPath:savePath error:&error];
            }
            
            [localFileManager createDirectoryAtPath:savePath withIntermediateDirectories:NO attributes:nil error:nil];
            
            NSArray *filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:projectPath error:&error];
            
            if (filesArray.count > 0)
            {
                for(NSString* file in filesArray)
                {
                    error = nil;
                    
                    NSString* fileToPath = [savePath stringByAppendingPathComponent:file];
                    NSString* fileFromPath = [projectPath stringByAppendingPathComponent:file];

                    NSData *data = [NSData dataWithContentsOfFile:fileFromPath];
                    [data writeToFile:fileToPath atomically:YES];
                }
            }
            
            _saveCount++;
            
            if (_saveCount == selectedProjectCount)
            {
                [[SHKActivityIndicator currentIndicator] hide];
                
                if ([self.projectGalleryPickerController.projectGalleryPickerDelegate respondsToSelector:@selector(projectGalleryPickerControllerDidCancel:)])
                {
                    [self.projectGalleryPickerController.projectGalleryPickerDelegate projectGalleryPickerControllerDidCancel:self.projectGalleryPickerController];
                }
            }
        }
    }
}


#pragma mark -
#pragma mark - Share a saved project

-(void)actionShareSavedProject:(id)sender
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    selectedProjectCount = 0;
    
    if (self.projectSelectionFlagArray.count == 0)
    {
        [self showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"You have not saved a project.... please save one so you can share.", nil) okHandler:nil];
        return;
    }
    
    for (int i = 0; i < self.projectSelectionFlagArray.count; i++)
    {
        BOOL isSelected = [[self.projectSelectionFlagArray objectAtIndex:i] boolValue];
        
        if (isSelected)
        {
            selectedProjectCount++;
        }
    }

    if (selectedProjectCount == 0)
    {
        [self showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"You have not selected a project for sharing!", nil) okHandler:nil];
        return;
    }
    
    //if ([self.appDelegate.projectSharingManager checkAvailablePeersForReceiving])   // show a connections list view
    {
        NSMutableArray* selectedProjectNames = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < self.projectSelectionFlagArray.count; i++)
        {
            BOOL isSelected = [[self.projectSelectionFlagArray objectAtIndex:i] boolValue];
            
            if (isSelected)
            {
                NSString* projectName = [self.projectNamesArray objectAtIndex:i];
                [selectedProjectNames addObject:projectName];
            }
        }
        
        [[SHKActivityIndicator currentIndicator] displayActivity:NSLocalizedString(@"Preparing...", nil) isLock:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *zipPaths = [NSMutableArray arrayWithArray:[self.appDelegate.projectSharingManager shareZippedProjects:selectedProjectNames]];
            [[SHKActivityIndicator currentIndicator] hide];
            NSLog(@"%@", zipPaths);
            [zipPaths addObject:@"VideoDreamer Sharing Projects"];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:zipPaths applicationActivities:nil];
            
            activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
                //[self dismissViewControllerAnimated:YES completion:nil];
            };
            
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                [self presentViewController:activityViewController animated:YES completion:nil];
            } else {
                TTOpenInAppActivity *openInAppActivity = [[TTOpenInAppActivity alloc]initWithView:self.view andRect:CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height , 0, 0)];
                
                activityViewController.modalPresentationStyle = UIModalPresentationPopover;
                activityViewController.popoverPresentationController.sourceView = self.view;
                activityViewController.popoverPresentationController.sourceRect = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height , 0, 0);
                activityViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
                [self presentViewController:activityViewController animated:YES completion:nil];
                
                openInAppActivity.superViewController = activityViewController;
            }
        });
        
        /*
        CGRect menuFrame = CGRectZero;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            menuFrame = CGRectMake(0.0f, 0.0f, 280.0f, 162.0f);
        else
            menuFrame = CGRectMake(0.0f, 0.0f, 400.0f, 162.0f);
        
        self.connectionsListView = nil;
        self.connectionsListView = [[ConnectionsListView alloc] initWithFrame:menuFrame];
        self.connectionsListView.projectNamesArray = [selectedProjectNamesArray copy];
        self.connectionsListView.delegate = self;
        
        self.customModalView = [[CustomModalView alloc] initWithViewController:self view:self.connectionsListView];
        self.customModalView.delegate = self;
        self.customModalView.dismissButtonRight = YES;
        [self.customModalView show];
        */
    }
    //else
    //{
    //    [self showAlertViewController:NSLocalizedString(@"Warning!", nil) message:NSLocalizedString(@"There are not any connected devices running the VideoDreamer app.", nil) okHandler:nil];
    //}
}


#pragma mark -
#pragma mark - ConnectionsListViewDelegate

-(void) didTapSendProject
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
}


#pragma mark - 
#pragma mark - CustomModalViewDelegate

-(void) didClosedCustomModalView
{
    
}

@end
