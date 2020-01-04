#import "CommandViewController.h"

#import "Config.h"
#import "AppDelegate.h"
#import "Ulysse.h"

@interface CommandViewController () {
  NSArray *_commandsAndSections;
}

@end

@implementation CommandViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  _commandsAndSections = @[
    @{
      @"commands": @[
        @{ @"name": @"Get Arduino Info", @"command": @"arduino_info"},
        @{ @"name": @"Update Arduino", @"command": @"arduino_update", @"alert": @{ @"question": @"Do you want to update the arduino?" }},
      ],
    },
    @{
      @"commands": @[
        @{ @"name": @"Update", @"command": @"update_pi", @"alert": @{ @"question": @"Do you want to update the Raspberry Pi?" }},
        @{ @"name": @"Reboot", @"command": @"reboot", @"alert": @{ @"question": @"Do you want to reboot the Raspberry Pi?" }},
        @{ @"name": @"Shutdown", @"command": @"shutdown", @"alert": @{ @"question": @"Do you want to shutdown the Raspberry Pi?" }},
      ],
    },
  ];
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
