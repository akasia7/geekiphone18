import UIKit
import NYXImagesKit
import NCMB
import UITextView_Placeholder
import SVProgressHUD


protocol AddPostViewControllerDelegate {
    func refreshData()
}

class AddPostViewController: UIViewController, UINavigationControllerDelegate,UITextViewDelegate {
    
    var delegate: AddPostViewControllerDelegate?
    
    @IBOutlet var postTextView: UITextView!
    
    @IBOutlet var postButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postTextView.placeholder = "思ったことを書き込もう！"
        postTextView.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        confirmContent()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    func confirmContent() {
    
    }
    
    @IBAction func share() {
        SVProgressHUD.show()

    }
    
    @IBAction func cancel() {
        if postTextView.isFirstResponder == true {
            postTextView.resignFirstResponder()
        }
        
        let alert = UIAlertController(title: "投稿内容の破棄", message: "入力中の投稿内容を破棄しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
            
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
