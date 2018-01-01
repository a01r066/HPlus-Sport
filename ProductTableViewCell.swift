//
//  ProductTableViewCell.swift
//  hplus-sport
//
//  Created by Saul Mora on 5/9/17.
//  Copyright © 2017 Lynda.com. All rights reserved.
//

import UIKit

let imageSession = URLSession(configuration: .ephemeral)

let cache = NSCache<NSURL, UIImage>()

func loadImage(from url: URL, completion: @escaping (UIImage) -> Void)
{
  if let image = cache.object(forKey: url as NSURL)
  {
    completion(image)
  }
  else
  {
    let task = imageSession.dataTask(with: url) { (imageData, _, _) in
      guard let imageData = imageData,
      let image = UIImage(data: imageData)
      else { return }
      
      cache.setObject(image, forKey: url as NSURL)
      DispatchQueue.main.async {
        completion(image)
      }
      
    }
    task.resume()
  }
}

class ProductTableViewCell: UITableViewCell
{
  @IBOutlet private weak var productName: UILabel!
  @IBOutlet private weak var productDescription: UILabel!
  @IBOutlet private weak var productImage: UIImageView!
  
  var product: Product?
  {
    didSet { display(product) }
  }
  
  static let cellIdentifier = String(describing: ProductTableViewCell.self)
  
  static func dequeueResuableCell<T: UITableViewCell>(from tableView: UITableView, at indexPath: IndexPath) -> T
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    return cell as? T ?? T(style: .default, reuseIdentifier: cellIdentifier)
  }

  private var generation = 0
  override func prepareForReuse()
  {
    super.prepareForReuse()
    productName.text = nil
    productDescription.text = nil
    productImage.image = nil
    generation += 1
  }
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    display(product)
  }

  private func display(_ product: Product?)
  {
    guard let product = product else { return }
    productName.text = product.name
    productDescription.text = product.description
    
    guard let imageURL = product.imageURL else { return }
    let currentGeneration = generation
    loadImage(from: imageURL) {
      guard currentGeneration == self.generation else { return }
      self.productImage.image = $0
    }
    
  }
}
