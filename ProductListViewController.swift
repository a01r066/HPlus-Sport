//
//  ProductsViewController.swift
//  hplus-sports
//
//  Created by Saul Mora on 2/12/17.
//  Copyright © 2017 Lynda.com. All rights reserved.
//

import UIKit
import Foundation

final class ProductListViewController: UIViewController
{
  @IBOutlet private var productsTableView: UITableView!
  
  var productPages: [PagedResult<Product>] = []
  {
    didSet
    {
      DispatchQueue.main.async {
        self.productsTableView.reloadData()
      }
    }
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    loadProducts()
  }
  
  override func viewDidAppear(_ animated: Bool)
  {
    super.viewDidAppear(animated)
    guard let selectedIndexPath = productsTableView.indexPathForSelectedRow else { return }
    productsTableView.deselectRow(at: selectedIndexPath, animated: animated)
  }
  
  var service = HPlusWebService()
  fileprivate func loadProducts(page: Int = 0, resultsPerPage: Int = 5)
  {
    service.products(page: page, resultsPerPage: resultsPerPage) { (productPage) in
      guard !self.loadedProductPageNumbers.contains(productPage.pageNumber) else { return }
      self.productPages.append(productPage)
      self.updateLastIndexPath(productPage)
    }
  }
  
  private(set) var lastIndexPath: IndexPath?
  func updateLastIndexPath(_ productPage: PagedResult<Product>)
  {
    if productPage.results.isEmpty
    {
      lastIndexPath = nil
    }
    else
    {
      lastIndexPath = calculateLastIndexPath()
    }
  }
  
  private func calculateLastIndexPath() -> IndexPath?
  {
    guard let lastPage = productPages.last else { return nil }
    let section = lastPage.pageNumber
    let row = lastPage.results.count - 1
    return IndexPath(row: row, section: section)
  }
  
  private var loadedProductPageNumbers: [Int]
  {
    return productPages.map { $0.pageNumber }
  }

  func product(at indexPath: IndexPath) -> Product?
  {
    guard indexPath.section < productPages.count else {
      return nil
    }
    guard indexPath.row < productPages[indexPath.section].results.count else {
      return nil
    }
    let page = productPages[indexPath.section]
    return page.results[indexPath.row]
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    guard
      let productViewController = segue.destination as? ProductViewController,
      let selectedIndexPath = productsTableView.indexPathForSelectedRow
    else
      { return }
    
    productViewController.product = product(at: selectedIndexPath)
  }
  
  @IBAction func exitToProductsView(segue: UIStoryboardSegue)
  {
  }
}

extension ProductListViewController: UITableViewDelegate
{
  fileprivate var nextPageIndex: Int
  {
    guard let lastPage = productPages.last else { return 0 }
    return lastPage.pageNumber.advanced(by: 1)
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
  {
    if indexPath == lastIndexPath
    {
      loadProducts(page: nextPageIndex)
    }
  }
}

extension ProductListViewController: UITableViewDataSource
{
  func numberOfSections(in tableView: UITableView) -> Int
  {
    return productPages.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    let page = productPages[section]
    return page.results.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell: ProductTableViewCell = .dequeueResuableCell(from: tableView, at: indexPath)
    
    cell.product = product(at: indexPath)
    
    return cell
  }
}

extension ProductListViewController: UINavigationBarDelegate
{
  func position(for bar: UIBarPositioning) -> UIBarPosition
  {
    return .topAttached
  }
}
