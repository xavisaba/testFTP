//
//  ViewController.m
//  FtpTest
//
//  Created by admin on 3/11/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize ftpManager,server,user,pass,url,popoverController,library,list,dirDest;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.ftpManager = [[FTPManager alloc]init];
    self.dirDest=@"directorio";
    self.url=@"213.27.244.107";
    self.user=@"procliprodt";
    self.pass=@"RzjQGw94";
    self.server = [FMServer serverWithDestination:self.url username:self.user password:self.pass];
    self.tvList.dataSource = self;
    self.tvList.delegate = self;
    self.connectivity=YES;
    self.list=[[NSMutableArray alloc]init];
    
}

-(void)viewDidAppear:(BOOL)animated{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tvList reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self setFtpManager:nil];
    [self setPopoverController:nil];
    [self setLibrary:nil];
    [self setTvList:nil];
    [self setList:nil];
}

- (IBAction)listFiles:(id)sender{
    if(self.dirDest){
        [server setDestination:[NSString stringWithFormat:@"%@/%@",self.url,self.dirDest]];
    }
    dispatch_queue_t queue = dispatch_queue_create("cola", NULL);
    dispatch_sync(queue, ^{
        self.list=[[NSMutableArray alloc]init];
        
        [list removeAllObjects];
        NSArray *listAux=[ftpManager contentsOfServer:server];
        for (int i=0;i<[listAux count];i++) {
            NSString *st=[NSString stringWithFormat:@"ftp://%@:%@@%@/%@",self.user,self.pass,self.server.destination,[[listAux objectAtIndex:i] objectForKey:@"kCFFTPResourceName"]];
            [self.list addObject:st];
        }
    });
    [[self tvList] reloadData];
    //[self getNextFileName];
}

-(int) getNextFileName{
    int result=0;
    dispatch_queue_t queue = dispatch_queue_create("cola", NULL);
    dispatch_sync(queue, ^{
        
        self.list=[[NSMutableArray alloc]init];
        
        [list removeAllObjects];
        NSArray *listAux=[ftpManager contentsOfServer:server];
        for (int i=0;i<[listAux count];i++) {
            NSString *st=[NSString stringWithFormat:@"ftp://%@:%@@%@/%@",self.user,self.pass,self.url,[[listAux objectAtIndex:i] objectForKey:@"kCFFTPResourceName"]];
            [self.list addObject:st];
        }
    });
    for (int i=0;i<[list count];i++) {
        NSString* fileExt = [[[list objectAtIndex:i ] lastPathComponent] pathExtension];
        NSLog(@"%@",fileExt);
        if ([fileExt isEqualToString:@"jpg"]) {
            result++;
        }
    }
    
    return result;
}

- (IBAction)deleteFiles:(id)sender {
    if(self.dirDest){
        [server setDestination:[NSString stringWithFormat:@"%@/%@",self.url,self.dirDest]];
    }
    dispatch_queue_t queue = dispatch_queue_create("cola", NULL);
    dispatch_sync(queue, ^{
        list=[ftpManager contentsOfServer:server];
        for (int i=0;i<[list count];i++) {
            [ftpManager deleteFileNamed:[[list objectAtIndex:i] objectForKey:@"kCFFTPResourceName"] fromServer:server];
            
        }
        [list removeAllObjects];
        [self.tvList reloadData];
    });
}

- (IBAction)uploadFiles:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"Elige" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Camara",@"Libreria", nil];
    [sheet showInView:self.view];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        [self iniciarCamara];
    }else if (buttonIndex == 1){
        [self iniciarLibreria];
    }
}

-(void) iniciarCamara{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [popoverController presentPopoverFromRect:CGRectMake(0.0, 0.0, 400.0, 400.0)
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    }
}

-(void) iniciarLibreria{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
    [popoverController presentPopoverFromRect:CGRectMake(0.0, 0.0, 400.0, 400.0)
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIAlertView *alert;
    if (error) {
        alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                           message:[error localizedDescription]
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
    }
    
}


-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if(self.connectivity){
        [self saveImageInFtp:image withFileName:[[NSNumber numberWithInt:[self getNextFileName]]stringValue] inDirectory:dirDest];
    }else{
        NSString *albumName=@"proClinic";
        [self saveImageInAlbum:image inAlbum:albumName withInfo:info];
    }
    
    [popoverController dismissPopoverAnimated:YES];
}

-(void) saveImageInAlbum: (UIImage*)image inAlbum:(NSString*) albumName withInfo:(NSDictionary *)info{
    self.library = [[ALAssetsLibrary alloc] init];
    
    [self.library addAssetsGroupAlbumWithName:albumName
                                  resultBlock:^(ALAssetsGroup *group) {
                                      NSLog(@"added album:%@", albumName);
                                      __block ALAssetsGroup* groupToAddTo;
                                      [self.library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                                                  usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                                                      if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName]) {
                                                                          NSLog(@"found album %@", albumName);
                                                                          groupToAddTo = group;
                                                                      }
                                                                  }
                                                                failureBlock:^(NSError* error) {
                                                                    NSLog(@"failed to enumerate albums:\nError: %@", [error localizedDescription]);
                                                                }];
                                      CGImageRef img = [image CGImage];
                                      [self.library writeImageToSavedPhotosAlbum:img
                                                                        metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
                                                                 completionBlock:^(NSURL* assetURL, NSError* error) {
                                                                     if (error.code == 0) {
                                                                         NSLog(@"saved image completed:\nurl: %@", assetURL);
                                                                         
                                                                         // try to get the asset
                                                                         [self.library assetForURL:assetURL
                                                                                       resultBlock:^(ALAsset *asset) {
                                                                                           // assign the photo to the album
                                                                                           [groupToAddTo addAsset:asset];
                                                                                           NSLog(@"Added %@ to %@", [[asset defaultRepresentation] filename], albumName);
                                                                                       }
                                                                                      failureBlock:^(NSError* error) {
                                                                                          NSLog(@"failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                                                                                      }];
                                                                     }
                                                                     else {
                                                                         NSLog(@"saved image failed.\nerror code %i\n%@", error.code, [error localizedDescription]);
                                                                     }
                                                                 }];

                                  }
                                 failureBlock:^(NSError *error) {
                                     NSLog(@"error adding album");
                                 }];
    }

- (void) saveImageInFtp: (UIImage *) image withFileName:(NSString*) fileName inDirectory:(NSString*) directory{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *error;
    NSString *fileDir=@"";
    if (directory!=nil) {
        fileDir = [documentsDirectory stringByAppendingPathComponent:directory];
        [self createDirectory:directory atFilePath:documentsDirectory];
        documentsDirectory=fileDir;
    }
    
    NSString *jpgPath = [NSString stringWithFormat:@"%@/%@.jpg",documentsDirectory,fileName];
    [UIImageJPEGRepresentation(image, 0.5) writeToFile:jpgPath atomically:YES];
    
    NSData *data1 = [[NSFileManager defaultManager] contentsAtPath:jpgPath];
    [server setDestination:url];
    if(self.dirDest){
        [ftpManager createNewFolder:directory atServer:server];
        [server setDestination:[NSString stringWithFormat:@"%@/%@",self.url,self.dirDest]];
    }
    
    [ftpManager uploadData:data1 withFileName:[NSString stringWithFormat:@"%@.jpg",fileName] toServer:server];
    
}

-(void)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath
{
    NSString *filePathAndDirectory = [filePath stringByAppendingPathComponent:directoryName];
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error])
    {
        NSLog(@"Create directory error: %@", error);
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *) tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    cell.textLabel.text = [list objectAtIndex:indexPath.row];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSURL *openUrl = [[ NSURL alloc ] initWithString: [self.list objectAtIndex:indexPath.row] ];
    [[UIApplication sharedApplication] openURL:openUrl];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}


@end
