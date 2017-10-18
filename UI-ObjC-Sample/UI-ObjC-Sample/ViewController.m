//
//  ViewController.m
//  UI-ObjC-Sample
//
//  Created by francesco.leoni on 01/09/17.
//  Copyright © 2017 Near. All rights reserved.
//

#import "ViewController.h"
@import NeariOSUI;

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Sample";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPermissionsDialog {
    NITPermissionsViewController *permissionsVC = [[NITPermissionsViewController alloc] init];
    [permissionsVC show];
}

- (void)showPermissionsDialogCustom {
    UIImage *baseUnknownImage = [UIImage imageNamed:@"gray-button"];
    UIImage *unknownImage = [baseUnknownImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 35, 0, 35)];
    UIImage *baseGrantedImage = [UIImage imageNamed:@"blue-button"];
    UIImage *grantedImage = [baseGrantedImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 35, 0, 35)];
    
    NITPermissionsViewController *permissionsVC = [[NITPermissionsViewController alloc] init];
    permissionsVC.headerImage = [UIImage imageNamed:@"NearIT"];
    permissionsVC.textColor = [UIColor blackColor];
    permissionsVC.isEnableTapToClose = NO;
    permissionsVC.unknownButton = unknownImage;
    permissionsVC.grantedButton = grantedImage;
    permissionsVC.grantedIcon = [UIImage imageNamed:@"green-dot"];
    [permissionsVC show];
}

- (void)showPermissionsDialogLocationsOnly {
    NITPermissionsViewController *permissionsVC = [[NITPermissionsViewController alloc] initWithType:NITPermissionsTypeLocationOnly];
    [permissionsVC show];
}

// MARK: - TableView datasource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sampleCell"];
    
    UILabel *title = [cell viewWithTag:40];
    UILabel *description = [cell viewWithTag:50];
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    title.text = @"Default permissions";
                    description.text = @"Request permissions for locations and notifications";
                    break;
                    
                case 1:
                    title.text = @"Custom permissions";
                    description.text = @"Custom UI";
                    break;
                    
                case 2:
                    title.text = @"Permissions";
                    description.text = @"Location Only";
                    break;
                    
                default:
                    title.text = @"Undefined";
                    description.text = @" - ";
                    break;
            }
            break;
            
        default:
            title.text = @"Undefined";
            description.text = @" - ";
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        switch (indexPath.row) {
            case 0:
                [self showPermissionsDialog];
                break;
                
            case 1:
                [self showPermissionsDialogCustom];
                break;
                
            case 2:
                [self showPermissionsDialogLocationsOnly];
                break;
                
            default:
                break;
        }
        default:
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Permissions";
            
        default:
            return nil;
    }
}

@end
