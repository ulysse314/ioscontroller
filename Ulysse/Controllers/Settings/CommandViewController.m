#import "CommandViewController.h"

#import "Config.h"
#import "AppDelegate.h"
#import "Ulysse.h"

@interface CommandViewController () {
  NSArray *_commandsAndSections;
}

@end

@implementation CommandViewController

+ (UIColor*)backgroundColor {
  return [UIColor colorWithRed:239./255. green:239./255. blue:244./255. alpha:1.0];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
  self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
  self.tableView.estimatedSectionHeaderHeight = 36;
  self.tableView.backgroundColor = [[self class] backgroundColor];
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  self.tableView.tableFooterView.backgroundColor = [[self class] backgroundColor];
  _commandsAndSections = @[
    @{
      @"header": @"Arduino",
      @"commands": @[
        @{ @"name": @"Reset Current Consumption", @"command": @"reset_current_consumption"},
        @{ @"name": @"Get Info", @"command": @"arduino_info"},
        @{ @"name": @"Update", @"command": @"update_arduino", @"alert": @{ @"question": @"Do you want to update the Arduino?" }},
        @{ @"name": @"Restart", @"command": @"restart_arduino", @"alert": @{ @"question": @"Do you want to reset the Arduion?" }},
      ],
    },
    @{
      @"header": @"Pi",
      @"commands": @[
        @{ @"name": @"Update", @"command": @"update_pi", @"alert": @{ @"question": @"Do you want to update the Raspberry Pi?" }},
        @{ @"name": @"Reboot", @"command": @"reboot", @"alert": @{ @"question": @"Do you want to reboot the Raspberry Pi?" }},
        @{ @"name": @"Shutdown", @"command": @"shutdown", @"alert": @{ @"question": @"Do you want to shutdown the Raspberry Pi?" }},
      ],
    },
  ];
}

- (void)viewWillAppear:(BOOL)animated {
  [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
  if (self.navigationController.topViewController == self) {
    [self.navigationController popViewControllerAnimated:NO];
  }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return _commandsAndSections.count;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  view.backgroundColor = [[self class] backgroundColor];
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 100, 100)];
  [view addSubview:label];
  NSDictionary *commands = _commandsAndSections[section];
  label.text = commands[@"header"];
  label.translatesAutoresizingMaskIntoConstraints = NO;
  [view addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:@"H:|-(8)-[label]-(>=8)-|"
                        options:NSLayoutFormatAlignAllCenterY
                        metrics:0
                        views:@{@"label":label}]];
  [view addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:@"V:|-(12)-[label]-(8)-|"
                        options:NSLayoutFormatAlignAllCenterY
                        metrics:0
                        views:@{@"label":label}]];
  return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSDictionary *commands = _commandsAndSections[section];
  return [commands[@"commands"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Command" forIndexPath:indexPath];
  NSArray *commands = [_commandsAndSections[indexPath.section] objectForKey:@"commands"];
  NSDictionary *command = commands[indexPath.row];
  cell.textLabel.text = command[@"name"];
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
  NSArray *commands = [_commandsAndSections[indexPath.section] objectForKey:@"commands"];
  NSDictionary *command = commands[indexPath.row];
  dispatch_block_t executeCommand = ^{
    [appDelegate.ulysse sendCommand:command[@"command"]];
    [self.navigationController popViewControllerAnimated:YES];
  };
  if (!command[@"alert"]) {
    executeCommand();
  } else {
    NSDictionary *alertData = command[@"alert"];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertData[@"question"] message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:command[@"name"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
      executeCommand();
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
  }
}

@end
