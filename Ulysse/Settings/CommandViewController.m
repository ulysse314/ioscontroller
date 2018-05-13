#import "CommandViewController.h"

#import "Config.h"
#import "AppDelegate.h"
#import "Ulysse.h"

@interface CommandViewController () {
  NSArray *_commands;
}

@end

@implementation CommandViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  _commands = @[
    @{ @"name": @"Reboot", @"command": @"reboot"},
    @{ @"name": @"Shutdown", @"command": @"shutdown"},
    @{ @"name": @"Update arduino", @"command": @"arduino_update"},
    @{ @"name": @"Arduino Info", @"command": @"arduino_info"},
  ];
}

- (void)viewWillDisappear:(BOOL)animated {
  if (self.navigationController.topViewController == self) {
    [self.navigationController popViewControllerAnimated:NO];
  }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _commands.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Command" forIndexPath:indexPath];
  NSDictionary *command = _commands[indexPath.row];
  cell.textLabel.text = command[@"name"];
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
  NSDictionary *command = _commands[indexPath.row];
  [appDelegate.ulysse sendCommand:command[@"command"]];
  [self.navigationController popViewControllerAnimated:YES];
}

@end
