//
//  ViewController.h
//  FtpTest
//
//  Created by admin on 3/11/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTPManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController : UIViewController <UITableViewDelegate>
//<UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) FTPManager *ftpManager;
@property (strong, nonatomic) FMServer *server;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *pass;
@property (strong, nonatomic) NSString *user;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (strong, atomic) ALAssetsLibrary* library;
@property (weak, nonatomic) IBOutlet UITableView *tvList;
@property BOOL connectivity;
@property (strong,nonatomic) NSMutableArray* list;
@property (strong,nonatomic) NSString *dirDest;

- (IBAction)listFiles:(id)sender;
- (IBAction)deleteFiles:(id)sender;
- (IBAction)uploadFiles:(id)sender;


@end

