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
    NITDialogController *dialogController = [[NITDialogController alloc] initWithViewController:permissionsVC];
    [self presentViewController:dialogController animated:YES completion:nil];
}

- (void)showPermissionsDialogCustom {
    NITPermissionsViewController *permissionsVC = [[NITPermissionsViewController alloc] init];
    permissionsVC.headerImage = [UIImage imageNamed:@"NearIT"];
    permissionsVC.textColor = [UIColor blackColor];
    permissionsVC.isEnableTapToClose = NO;
    NITDialogController *dialogController = [[NITDialogController alloc] initWithViewController:permissionsVC];
    [self presentViewController:dialogController animated:YES completion:nil];
}

// MARK: - TableView datasource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sampleCell"];
    
    UILabel *title = [cell viewWithTag:40];
    UILabel *description = [cell viewWithTag:50];
    
    switch (indexPath.row) {
        case 0:
            title.text = @"Permissions";
            description.text = @"Request permissions for locations and notifications";
            break;
            
        case 1:
            title.text = @"Permissions";
            description.text = @"Custom UI";
            break;
            
        default:
            title.text = @"Undefined";
            description.text = @" - ";
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self showPermissionsDialog];
            break;
            
        case 1:
            [self showPermissionsDialogCustom];
            break;
            
        default:
            break;
    }
}

@end
