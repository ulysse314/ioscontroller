#import "BoatChooserViewController.h"

#import "Config.h"
#import "AppDelegate.h"

@interface BoatChooserViewController () {
  NSArray *_boatNames;
}

@end

@implementation BoatChooserViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  _boatNames = [Config sharedInstance].boatNameList;
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  if (self.navigationController.topViewController == self) {
    [self.navigationController popViewControllerAnimated:NO];
  }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _boatNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BoatName" forIndexPath:indexPath];
  NSString *boatName = _boatNames[indexPath.row];
  cell.textLabel.text = boatName;
  if ([[Config sharedInstance].boatName isEqualToString:boatName]) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [Config sharedInstance].boatName = _boatNames[indexPath.row];
  [self.navigationController popViewControllerAnimated:YES];
}

@end
