import UIKit

class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinAccountTextView: UITextView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var activeTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.clipsToBounds = true
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let atributedString = NSMutableAttributedString(string: "Already have an account? Sign in here.", attributes: [.font: Font.caption])
        atributedString.addAttribute(.link, value: "instantcreate://createAccount", range: (atributedString.string as NSString).range(of: "Sign in here."))
        signinAccountTextView.attributedText = atributedString
        signinAccountTextView.linkTextAttributes = [.foregroundColor: UIColor.secondaryColor, .font: Font.linkLabel]
        signinAccountTextView.delegate = self
        signinAccountTextView.isScrollEnabled = false
        signinAccountTextView.textAlignment = .center
        signinAccountTextView.isEditable = false
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)) // убираем клавиатуру по тапу на экран
        view.addGestureRecognizer(backgroundTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboarNotifications()
    }
    
    func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    // метод для удаления уведомлений когда клавиатура исчезнет
    func removeKeyboarNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.cornerRadius = 20
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardOffset = view.convert(keyboardFrame.cgRectValue, from: nil).size.height  // высота клавиатуры
        let totalOffset = activeTextField == nil ? keyboardOffset : keyboardOffset + activeTextField!.frame.height // общее смещение
        scrollView.contentInset.bottom = totalOffset
    }
    
    // Когда клавиатура скрыта мы возвращаем все занчения в исходное положение
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
    
    // Метод сктытия клавиатуры
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func createAccountButtonTapped(_ sender: Any) {
        
    }

}

extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextField = nil
    }
}

extension CreateAccountViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "instantcreate" {
            performSegue(withIdentifier: "SignInSegue", sender: nil)
        }
        return false
    }
}
