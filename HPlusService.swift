//
//  HPlusService.swift
//  hplus-sport
//
//  Created by Saul Mora on 5/16/17.
//  Copyright © 2017 Lynda.com. All rights reserved.
//

import Foundation

protocol HPlusService
{
  typealias ProductPageCompletion = (PagedResult<Product>) -> Void
  func products(page: Int, resultsPerPage: Int, completion: @escaping ProductPageCompletion)
  
// The HPlus API you'll need to download product details is:
// http://hplussport.com/api/products/id/<id>
//
//  The steps required to implement this function are
//  1. Create a URL from the URL template
//  2. Create a session task, similar to the products implementation below
//  3. When the data has completed, in the completion block, parse the new data object
//  4. After you have a valid object, in the ProductListViewController, you can 
//      call performSegue("showProduct", sender: self), and in prepareForSegue,
//      pass the product object that was downloaded to the next view controller
//      (which will be a ProductViewController)
//  5. And, to trigger this function from the UI, you might call this when a product
//      cell is tapped, which triggers the showProduct segue. You can override
//      shouldPerformSegue and return false while you're waiting for the product
//      data to return.
//
//  typealias ProductCompletion = (Product) -> Void
//  func product(id productID: Int, completion: @escaping ProductCompletion)
}

class HPlusWebService: HPlusService
{
  func products(page: Int, resultsPerPage: Int, completion: @escaping (PagedResult<Product>) -> Void) {
    let url = URL(string: "https://hplussport.com/api/products/page/\(page)/qty/\(resultsPerPage)")!
    let task = session.dataTask(with: url) { (data, response, error) in
      guard let data = data else { return }
      do {
        try validate(response)
        
        let products: [Product] = try parse(data)
        let productPage = PagedResult(pageNumber: page, results: products)
        completion(productPage)
      }
      catch {
        print("Error: \(error)")
      }
    }
    task.resume()
  }
}
