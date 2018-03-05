//
//  ConstantsTableViewController.m
//  Calculator Pro
//
//  Created by Lucas Popp on 10/23/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import "ConstantsTableViewController.h"
#import "ViewController.h"

@interface ConstantsTableViewController ()

@property (strong, nonatomic) NSUserDefaults *defaults;

@property (strong, nonatomic) NSString *constant;

@property (strong, nonatomic) NSMutableArray *constants;

@end

@implementation ConstantsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Constants";
    
    self.constant = @"";
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newConstant)],
                                                self.editButtonItem];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    
    self.constants = [[NSMutableArray alloc] initWithArray:[self.defaults objectForKey:@"Constants"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel {
    ((ViewController *)self.navigationController.presentingViewController).constant = self.constant;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)newConstant {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Constant" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Name";
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Value";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (![alert.textFields[0].text isEqual:@""] && ![alert.textFields[1].text isEqual:@""]) {
            [self.constants addObject:@{
                                        @"Name" : alert.textFields[0].text,
                                        @"Value" : alert.textFields[1].text
                                        }];
            
            [self saveConstants];
            [self.tableView reloadData];
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveConstants {
    [self.defaults setObject:[[NSArray alloc] initWithArray:self.constants] forKey:@"Constants"];
    [self.defaults synchronize];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.constants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell Identifier";
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text = self.constants[indexPath.row][@"Name"];
    cell.detailTextLabel.text = self.constants[indexPath.row][@"Value"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.constant = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
    
    ((ViewController *)self.navigationController.presentingViewController).constant = self.constant;
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [self.constants removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self saveConstants];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSDictionary *movedConstant = [[NSDictionary alloc] initWithDictionary:self.constants[fromIndexPath.row]];
    
    [self.constants removeObjectAtIndex:fromIndexPath.row];
    [self.constants insertObject:movedConstant atIndex:toIndexPath.row];
    [self saveConstants];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

@end
