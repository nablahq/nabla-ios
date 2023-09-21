import UIKit
import MapboxMaps
import MapboxSearch

protocol SearchViewTextFieldDelegate {
    func updateTextfieldPlaceholder(text: String)
}

class SearchViewController: PullUpController, UITextFieldDelegate, SearchViewTextFieldDelegate {
    
    enum InitialState {
        case contracted
        case expanded
    }
    
    var initialState: InitialState = .contracted
    
    let searchEngine = SearchEngine()
        
    lazy var searchBoxContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.9)
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = UIColor(white: 1, alpha: 0.9)
        tv.separatorStyle = .singleLine
        tv.separatorColor = .lightGray
        return tv
    }()
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.withImage(direction: .Left, image: UIImage(named: "search")!, colorSeparator: .clear, colorBorder: .black)
        tf.tintColor = .black
        tf.placeholder = "Search..."
        tf.clearButtonMode = .always
        return tf
    }()
    
    let responseLabel = UILabel()
        
    private var suggestionsArray: [SearchSuggestion] = []

    public var portraitSize: CGSize = .zero
        
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        portraitSize = CGSize(width: UIScreen.main.bounds.width,
                              height: UIScreen.main.bounds.height - (UIScreen.main.bounds.height*0.15))
        
        tableView.attach(to: self)
        
        view.addSubview(searchBoxContainerView)
        view.addSubview(tableView)
                
        searchBoxContainerView.addSubview(textField)
        textField.anchor(searchBoxContainerView.topAnchor, left: searchBoxContainerView.leftAnchor, bottom: nil, right: searchBoxContainerView.rightAnchor, topConstant: 20, leftConstant: 24, bottomConstant: 0, rightConstant: 24, widthConstant: 0, heightConstant: 45)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: "SearchResultCell")

        
        searchBoxContainerView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 120)
        
        tableView.anchor(searchBoxContainerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        textField.addTarget(self, action: #selector(textFieldTextDidChanged), for: .editingChanged)
         
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 25
        
        searchEngine.delegate = self
                
        textField.delegate = self
        
        let addPlaceController = AddPlaceController()
        addPlaceController.delegate = self
    }
    
    func updateTextfieldPlaceholder(text: String) {
        print("uslo...")
        textField.placeholder = text
    }
    
    @objc func textFieldTextDidChanged() {
        searchEngine.search(query: textField.text!)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textfield become active")
        pullUpControllerMoveToVisiblePoint(UIScreen.main.bounds.height - (UIScreen.main.bounds.height * 0.15), animated: true, completion: nil)
    }
    
    // MARK: - PullUpController
    
    override var pullUpControllerPreferredSize: CGSize {
        return portraitSize
    }
    
    override var pullUpControllerMiddleStickyPoints: [CGFloat] {
        switch initialState {
        case .contracted:
            return [120]
        case .expanded:
            return [searchBoxContainerView.frame.maxY + 20, view.frame.maxY]
        }
    }
    
    override func pullUpControllerAnimate(action: PullUpController.Action,
                                          withDuration duration: TimeInterval,
                                          animations: @escaping () -> Void,
                                          completion: ((Bool) -> Void)?) {
        switch action {
        case .move:
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut,
                           animations: animations,
                           completion: completion)
        default:
            UIView.animate(withDuration: 0.3,
                           animations: animations,
                           completion: completion)
        }
    }
    
}

extension SearchViewController: SearchEngineDelegate {
    func resultResolved(result: MapboxSearch.SearchResult, searchEngine: MapboxSearch.SearchEngine) {
        (parent as? AddPlaceController)?.mapView.camera.fly(to: .init(center: result.coordinate, zoom: 15), duration: 0.25, completion: nil)
        (parent as? AddPlaceController)?.setCurrentPlace(coordinate: result.coordinate)
        print("Dumping resolved result:", dump(result))
    }
    
    func searchErrorHappened(searchError: MapboxSearch.SearchError, searchEngine: MapboxSearch.SearchEngine) {
        print("Error during search: \(searchError)")
    }
    
    func suggestionsUpdated(suggestions: [SearchSuggestion], searchEngine: SearchEngine) {
        suggestionsArray.removeAll(keepingCapacity: false)
        suggestionsArray.append(contentsOf: suggestions)
        tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
        
        cell.backgroundColor = .clear
        
        let distance = suggestionsArray[indexPath.row].distance?.magnitude ?? 0
        
        let formatter = MeasurementFormatter()

        // Working with meters and evaluating the results
        let distanceInMeters = Measurement(value: distance, unit: UnitLength.meters)
        formatter.unitOptions = .naturalScale
        let finalDistance  = formatter.string(from: distanceInMeters) // prints "2 metres"
        
        cell.configure(title: suggestionsArray[indexPath.row].name, subtitle: finalDistance)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
        pullUpControllerMoveToVisiblePoint(pullUpControllerMiddleStickyPoints[0], animated: true, completion: nil)
        
        searchEngine.select(suggestion: suggestionsArray[indexPath.row])
    }
}
