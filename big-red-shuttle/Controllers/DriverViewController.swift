import UIKit

class DriverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let data = UserDefaults.standard
    let masterKey = "brsxappdev2016"
    let cellHeight: CGFloat = 49
    let headerHeight: CGFloat = 42
    let footerHeight: CGFloat = 55
    let leftOffset: CGFloat = 12
    let cellLeftOffset: CGFloat = 17
    let cellTextOffset: CGFloat = 51
    let authImageLength: CGFloat = 21
    let incorrectAuthKeyText: String = "Your Authentication Key is incorrect. You are currently not logging the shuttle location."
    let noLoggingText: String = "You are currently not logging the shuttle location. Click the toggle to start logging."
    let loggingText: String = "You are now logging the location of your phone to the application and everyone on the network. Please turn off logging while you are not on the shuttle."
    
    var tableView: UITableView!
    var loginImage: UIImage?
    var keyTextField: UITextField?
    var footerLabel: UILabel?
    var isLoggingOn = false
    var textFieldText: String = ""
    var loginSuccessful: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        let closeButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissVC))
        closeButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.brsblack,
            NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Medium", size: 15.0)!], for: .normal)
        navigationItem.rightBarButtonItem = closeButton
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.backgroundColor = .brslightgrey
        view.addSubview(tableView)
    }
    
    // MARK: - Action Functions
    
    @objc func textFieldDidChange(textField: UITextField) {
        let enteredCorrectKey = (textField.text == masterKey)
        
        loginImage = (keyTextField?.text != "") ? (enteredCorrectKey ? #imageLiteral(resourceName: "CorrectIcon") : #imageLiteral(resourceName: "IncorrectIcon")) : nil
        textFieldText = enteredCorrectKey ? masterKey : textField.text!
        loginSuccessful = enteredCorrectKey
        
        tableView.reloadData()
    }
    
    @objc func didToggleLogging(loggingSwitch: UISwitch) {
        isLoggingOn = loggingSwitch.isOn
        
        if isLoggingOn {
            // MARK: start logging location
        } else {
            // MARK stop logging location
        }
        
        tableView.reloadData()
    }
    
    func updateFooterLabel() {
        var footerString = ""
        
        if loginSuccessful && isLoggingOn {
            footerString = loggingText
        } else if loginSuccessful && !isLoggingOn {
            footerString = noLoggingText
        } else if !loginSuccessful && keyTextField?.text != "" {
            footerString = incorrectAuthKeyText
        }
        
        footerLabel?.text = footerString
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table View Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let cellLabel = UILabel(frame: CGRect(x: cellTextOffset, y: 0, width: tableView.frame.width, height: cellHeight))
        cellLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 16.0)

        if indexPath.row == 0 {
            cellLabel.text = "Authentication Key"
            cellLabel.textColor = .offblack
            
            keyTextField = UITextField(frame: CGRect(x: 0, y: 0, width: cell.bounds.width/2, height: cellHeight))
            keyTextField?.center.y = cellHeight/2.0
            
            if let loginImage = loginImage {
                let authImageView = UIImageView(frame: CGRect(x: cellLeftOffset, y: 0, width: authImageLength, height: authImageLength))
                authImageView.center.y = cellHeight/2.0
                authImageView.image = loginImage
                cell.addSubview(authImageView)
                
                keyTextField?.text = textFieldText
            }
        
            keyTextField?.placeholder = "Insert Key"
            keyTextField?.font = UIFont(name: "SFUIDisplay-Regular", size: 16.0)
            keyTextField?.textColor = .brsgrey
            keyTextField?.textAlignment = .right
            keyTextField?.returnKeyType = .go
            keyTextField?.isSecureTextEntry = true
            keyTextField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidEndOnExit)
            cell.accessoryView = keyTextField
        } else {
            cell.isUserInteractionEnabled = loginSuccessful
            cellLabel.textColor = loginSuccessful ? .offblack : .brsgrey
            cellLabel.text = "Log Location"
            
            let logSwitch = UISwitch()
            logSwitch.tintColor = .switchtintgrey
            logSwitch.isOn = loginSuccessful && isLoggingOn
            logSwitch.addTarget(self, action: #selector(didToggleLogging), for: .valueChanged)
            cell.accessoryView = logSwitch
        }
        
        cellLabel.sizeToFit()
        cellLabel.center.y = cellHeight/2.0
     
        cell.addSubview(cellLabel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x: leftOffset, y: 21, width: tableView.frame.width, height: 20))
        headerLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 12.0)
        headerLabel.text = "Logging Login"
        headerLabel.textColor = .logginggrey
        headerLabel.sizeToFit()
        
        let headerView = UIView()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footerLabel = UILabel(frame: CGRect(x: leftOffset, y: 10, width: tableView.frame.width, height: 20))
        footerLabel?.font = UIFont(name: "SFUIDisplay-Regular", size: 12.0)
        footerLabel?.textColor = .logginggrey
        footerLabel?.lineBreakMode = .byWordWrapping
        footerLabel?.numberOfLines = 0
        updateFooterLabel()
        footerLabel?.sizeToFit()
        footerLabel?.frame.size.width = tableView.frame.width - 2*leftOffset
        
        let footerView = UIView()
        footerView.addSubview(footerLabel!)
        
        return footerView
    }
    
    // MARK: - Table View Delegate Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
