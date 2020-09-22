//
//  ViewController.m
//  Liverpool LookUp
//
//  Created by Karlo A. López on 21/09/20.
//  Copyright © 2020 Karlo A. López. All rights reserved.
//

#import "ViewController.h"
#import "Product.h"
#import "ProductTableViewCell.h"

@interface ViewController () <UISearchBarDelegate>{
    NSMutableArray *productData;
    int currentPage;
    int itemsPerPage;
    int currentTotalNumRecs;
    NSString *lastInputString;
    UIScrollView *historyScrollView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!productData){
        productData = [[NSMutableArray alloc] init];
    }
    
    //Will show footer ("Load More") if there are any more results
    [self.tableView.tableFooterView setHidden:YES];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Initial API call
    currentPage = 1;
    itemsPerPage = 10;
    currentTotalNumRecs = 0;
    lastInputString = @"XBOX";
    self.inputSearchBar.text = @"XBOX";
    
    [self makeLiverpoolRequestFor:lastInputString pageNumber:currentPage itemsPerPage:itemsPerPage];
    [self buildRecentSearchesView];
}

-(void) buildRecentSearchesView{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *searchHistory = [userDefaults objectForKey:@"searchHistory"];
    
    UIView *resultsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width, 25)];
    titleLabel.text = @"Buscado recientemente:";
    
    historyScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 25, self.view.frame.size.width, 65)];
    
    CGFloat elementWidth = self.view.frame.size.width / 2;
    CGFloat contentWidth = searchHistory.count * elementWidth;
    
    [historyScrollView setContentSize:CGSizeMake(contentWidth, 65)];
    
    for (int i = 0; i<searchHistory.count;i++) {
        NSString *historyElement = (NSString *)[searchHistory objectAtIndex:i];
        UILabel *historyLabel = [[UILabel alloc] initWithFrame:CGRectMake(i*elementWidth, 0, elementWidth, 65)];
        historyLabel.text = historyElement;
        historyLabel.textAlignment = UITextAlignmentCenter;
        historyLabel.font = [UIFont systemFontOfSize:18.0f weight:UIFontWeightBold];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelecHistoryItem:)];
        [historyLabel setUserInteractionEnabled:YES];
        [historyLabel addGestureRecognizer:tapGesture];
        
        [historyScrollView addSubview:historyLabel];
    }
    
    resultsView.backgroundColor = [UIColor whiteColor];
    [resultsView addSubview:titleLabel];
    [resultsView addSubview:historyScrollView];
    
    self.inputSearchBar.searchTextField.inputAccessoryView = resultsView;
    
}

-(void)didSelecHistoryItem:(UIGestureRecognizer *) gesture{
    UITextView *selectedText = (UITextView *) gesture.view;
    if(selectedText){
        if(selectedText.text.length > 0){
            [self resetSearchForString:selectedText.text saveHistory:NO];
            self.inputSearchBar.text = selectedText.text;
            [self.inputSearchBar resignFirstResponder];
        }
    }
}

-(void) appendHistoryString:(NSString *) historySearch{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *currentHistory;
    if([userDefaults objectForKey:@"searchHistory"]){
        currentHistory = [userDefaults objectForKey:@"searchHistory"];
    }
    
    NSMutableArray *tempHistory = [[NSMutableArray alloc] initWithArray:currentHistory];
    
    [tempHistory addObject:historySearch];
    
    [userDefaults setObject:tempHistory forKey:@"searchHistory"];
    
    [userDefaults synchronize];
    
    //Add to history scroll view
    CGFloat elementWidth = self.view.frame.size.width / 2;
    CGFloat newContentWidth = historyScrollView.contentSize.width + elementWidth;
    UILabel *historyLabel = [[UILabel alloc] initWithFrame:CGRectMake(newContentWidth-elementWidth, 0, elementWidth, 65)];
    historyLabel.text = historySearch;
    historyLabel.textAlignment = UITextAlignmentCenter;
    historyLabel.font = [UIFont systemFontOfSize:18.0f weight:UIFontWeightBold];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelecHistoryItem:)];
    [historyLabel setUserInteractionEnabled:YES];
    [historyLabel addGestureRecognizer:tapGesture];
    
    [historyScrollView setContentSize:CGSizeMake(newContentWidth, historyScrollView.contentSize.height)];
    [historyScrollView addSubview:historyLabel];
    
}

-(void) makeLiverpoolRequestFor:(NSString *)searchItem pageNumber:(int)pNumber itemsPerPage:(int)iPerPage{
    
    NSString *baseApiUrl = @"https://shoppapp.liverpool.com.mx/appclienteservices/services/v3/plp?force-%20plp=true";

    //Check if search string is valid
    if(searchItem == (id)[NSNull null] || searchItem.length == 0 ){
        //Search string is empty, do nothing.
        NSLog(@"Search string is empty.");
        return;
    }
    
    //Build GET request URL with values
    NSString *requestString = [NSString stringWithFormat:@"%@&search-string=\"%@\"&page-number=%i&number-of-items-per-page=%i",baseApiUrl, searchItem, pNumber, iPerPage];
    
    //Clean request string for encoding characters
    NSString *escapedPath = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    
    NSLog(@"Request String %@", requestString);
    
    //Build NSURLSession and Request for an asynch call
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:escapedPath]];
    [urlRequest setHTTPMethod:@"GET"];

    NSURLSession *session = [NSURLSession sharedSession];
    __block NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      if(httpResponse.statusCode == 200)
      {
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
          if([responseDictionary objectForKey:@"plpResults"]){
              
              //Get amount of result records
              if([[responseDictionary objectForKey:@"plpResults"] objectForKey:@"plpState"]){
                  if([[[responseDictionary objectForKey:@"plpResults"] objectForKey:@"plpState"] objectForKey:@"totalNumRecs"]){
                      currentTotalNumRecs = [[[[responseDictionary objectForKey:@"plpResults"] objectForKey:@"plpState"] objectForKey:@"totalNumRecs"] intValue];
                  }
              }
              
              if([[responseDictionary objectForKey:@"plpResults"] objectForKey:@"records"]){
                  NSArray *records = [[responseDictionary objectForKey:@"plpResults"] objectForKey:@"records"];
                  for(int i = 0; i < records.count; i++){
                      Product *newProduct = [[Product alloc]init];
                      NSDictionary *currentProduct = records[i];
                      [newProduct setProductData:currentProduct];
                      [productData addObject:newProduct];
                  }
                  NSLog(@"%i", productData.count);
                  //Update on the main thread
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if(productData.count < currentTotalNumRecs){
                          //There are still records
                          [self.tableView.tableFooterView setHidden:NO];
                      }else{
                          [self.tableView.tableFooterView setHidden:YES];
                      }
                      [self.tableView reloadData];
                  });
              }
          }
        //NSLog(@"The response is - %@",responseDictionary);
      }
      else
      {
        NSLog(@"Error making request.");
      }
    }];
    [dataTask resume];
}

-(void) resetSearchForString:(NSString *) searchString saveHistory:(BOOL)saveIt{
   
    [productData removeAllObjects];
    
    if(saveIt){
        [self appendHistoryString:searchString];
    }
    
    currentPage = 1;
    itemsPerPage = 10;
    currentTotalNumRecs = 0;
    lastInputString = searchString;
    
    [self makeLiverpoolRequestFor:lastInputString pageNumber:currentPage itemsPerPage:itemsPerPage];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    
    if(!productData){
        return 0;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    
    if(!productData){
        return 0;
    }
    
    return productData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProductTableViewCell *productCell = [tableView dequeueReusableCellWithIdentifier:@"productTableViewCell" forIndexPath:indexPath];
    
    Product *currentProduct = (Product *)[productData objectAtIndex:indexPath.row];
    
    // Configure the cell...
    productCell.productTitleLabel.text = currentProduct.productDisplayName;
    productCell.productPriceLabel.text = currentProduct.listPriceDisplay;
    productCell.productDescLabel.text = @"";
    
    //Load image async
    if(currentProduct.lgImage){
        if(currentProduct.lgImage.length > 0){
            NSURL *imageUrl = [NSURL URLWithString:currentProduct.lgImage];

            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:imageUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    UIImage *productImage = [UIImage imageWithData:data];
                    if (productImage) {
                        //Update on the main thread
                        dispatch_async(dispatch_get_main_queue(), ^{
                            ProductTableViewCell *mainThreadCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                            if (mainThreadCell){
                                mainThreadCell.productImageView.image = productImage;
                            }
                        });
                    }
                }
            }];
            [task resume];
        }
    }
    
    
    
    return productCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self resetSearchForString:self.inputSearchBar.text saveHistory:YES];
    [self.inputSearchBar resignFirstResponder];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loadMoreAction:(id)sender {
    currentPage = currentPage + 1;
    [self makeLiverpoolRequestFor:lastInputString pageNumber:currentPage itemsPerPage:itemsPerPage];
}
@end
