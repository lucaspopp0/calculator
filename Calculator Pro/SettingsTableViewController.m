//
//  SettingsTableViewController.m
//  Calculator Pro
//
//  Created by Lucas Popp on 11/29/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "AboutViewController.h"
#import "CalculatorButton.h"

@interface SettingsTableViewController ()

@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) UISegmentedControl *appearanceControl;

@property (strong, nonatomic) CalculatorButton *appearanceButton;

@end

@implementation SettingsTableViewController

- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style {
    if (self == [super initWithStyle:style]) {
        self.defaults = [NSUserDefaults standardUserDefaults];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        self.title = @"Settings";
        
        self.appearanceControl = [[UISegmentedControl alloc] initWithItems:@[@"Normal", @"Dot", @"Full"]];
        self.appearanceControl.frame = CGRectMake(16.0f, (44.0f - 31.0f) / 2.0f, self.tableView.frame.size.width - 32.0f, 31.0f);
        [self.appearanceControl addTarget:self action:@selector(selectAppearance:) forControlEvents:UIControlEventValueChanged];
        
        CGSize buttonSize = CGSizeMake(self.tableView.frame.size.width / 5.0f,
                                       ([UIScreen mainScreen].bounds.size.height - (20.0f + [UIScreen mainScreen].bounds.size.width * (2.0f / 3.0f))) / 7.0f);
        
        self.appearanceButton = [[CalculatorButton alloc] initWithFrame:CGRectMake((self.tableView.frame.size.width - buttonSize.width) / 2.0f,
                                                                                   self.appearanceControl.frame.origin.y + self.appearanceControl.frame.size.height + 8.0f,
                                                                                   buttonSize.width, buttonSize.height)];
        self.appearanceButton.title = @"log";
        self.appearanceButton.secondTitle = @"e\u02E3";
        self.appearanceButton.thirdTitle = @"e";
        self.appearanceButton.style = CalculatorButtonStyleDark;
        
        self.appearanceControl.selectedSegmentIndex = [[self.defaults objectForKey:@"Button Appearance"] integerValue];
        [self selectAppearance:self.appearanceControl];
    }
    
    return self;
}

- (void)done {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectAppearance:(UISegmentedControl *)sender {
    [self.defaults setObject:@(sender.selectedSegmentIndex) forKey:@"Button Appearance"];
    [self.defaults synchronize];
    
    self.appearanceButton.appearance = (CalculatorButtonAppearance)sender.selectedSegmentIndex;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            
        case 1:
            return 1;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"Cell Identifier";
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    for (UIView *subview in cell.subviews) {
        if ([subview isKindOfClass:[UISegmentedControl class]] || [subview isKindOfClass:[CalculatorButton class]]) {
            [subview removeFromSuperview];
        }
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"About";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [cell addSubview:self.appearanceControl];
            [cell addSubview:self.appearanceButton];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        return 110.0f;
    } else {
        return 44.0f;
    }
}

#pragma mark UITableViewDelgate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        AboutViewController *aboutController = [[AboutViewController alloc] init];
        aboutController.title = @"About";
        
        [self.navigationController pushViewController:aboutController animated:YES];
    }
}

@end
