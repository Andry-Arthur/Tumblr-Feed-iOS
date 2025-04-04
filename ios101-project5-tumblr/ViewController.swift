//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    private var posts: [Post] = []
    private let refreshControl = UIRefreshControl()
    
    // ✅ Toggle state to alternate between blogs
    private var useFirstBlog = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable dynamic row heights
        tableView.rowHeight = 200
        tableView.dataSource = self
        
        // Set up refresh control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        fetchPosts()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("🍏 cellForRowAt called for row: \(indexPath.row)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        
        cell.summaryLabel.text = post.summary
        print("🍏 Setting summary for row \(indexPath.row): \(post.summary)")
        
        if let photo = post.photos.first {
            let imageUrl = photo.originalSize.url
            Nuke.loadImage(with: imageUrl, into: cell.postImageView)
            print("🍏 Loading image from URL: \(imageUrl)")
        } else {
            cell.postImageView.image = nil
            print("🍏 No image available for row \(indexPath.row)")
        }
        
        return cell
    }
    
    func fetchPosts() {
        // ✅ Alternate between two blog URLs
        let urlString: String
        if useFirstBlog {
            urlString = "https://api.tumblr.com/v2/blog/hestaprynn/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk"
        } else {
            urlString = "https://api.tumblr.com/v2/blog/careerwithbooks/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk"
        }
        useFirstBlog.toggle() // ✅ Flip flag for next refresh
        
        print("🌐 Fetching from URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            refreshControl.endRefreshing()
            return
        }
        
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
                return
            }
            
            guard let data = data else {
                print("❌ Data is NIL")
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
                return
            }
            
            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.posts = blog.response.posts
                    self.tableView.reloadData()
                    
                    print("✅ We got \(self.posts.count) posts!")
                    for post in self.posts {
                        print("🍏 Summary: \(post.summary)")
                    }

                    self.refreshControl.endRefreshing()
                }
                
            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
            }
        }
        session.resume()
    }
    
    @objc func refreshData() {
        print("🔄 Refreshing data...")
        fetchPosts()
    }
}
