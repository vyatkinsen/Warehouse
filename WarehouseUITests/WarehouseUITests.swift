import XCTest

final class WarehouseUITests: XCTestCase {
    
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        
        try super.tearDownWithError()
    }
    
    func testAuth() {
        let login = app.textFields["Логин"]
        login.typeText("test")
        
        let pass = app.secureTextFields["Пароль"]
        pass.tap()
        pass.typeText("123\n")
    }
    
    func testHomeTabNavigation() throws {
        let tabBar = app.tabBars.firstMatch

        let homeTab = tabBar.buttons["Главная"]
        XCTAssertTrue(homeTab.exists, "Кнопка 'Главная' должна существовать в таббаре")

        homeTab.tap()
    }
    
    func testQRTabNavigation() throws {
        let tabBar = app.tabBars.firstMatch

        let qrTab = tabBar.buttons["Сканер"]
        XCTAssertTrue(qrTab.exists, "Кнопка 'Сканер' должна существовать в таббаре")

        qrTab.tap()
    }
    
    func testProjectsList() throws {
        try testHomeTabNavigation()
        let button = app.buttons["UITest"]
        button.tap()
    }
    
    
    func testWarehousesList() throws {
        try testProjectsList()
        let button = app.buttons["Большой"]
        button.tap()
    }
    
    func testAddProduct() throws {
        try testWarehousesList()
        addProduct(name: "Test")
        
        XCTAssertTrue(app.cells.staticTexts["Test"].exists)
    }
    
    private func addProduct(name: String) {
        let addNewProductButton = app.buttons["addNewProductButton"]
        XCTAssertTrue(addNewProductButton.exists, "Кнопка 'addNewProductButton' должна существовать")
        addNewProductButton.tap()
        
        let nameField = app.textFields["nameField"]
        nameField.tap()
        nameField.typeText("\(name)\n")
        
        let stepper = app.steppers["quantityStepper"]
        stepper.buttons["Increment"].tap()

        let addButton = app.buttons["addOrUpdateButton"]
        addButton.tap()
    }
    
    func testSorting() throws {
        try testHomeTabNavigation()
        try testWarehousesList()

        let sortNameZA: String = "ЯЯЯЯ"
        addProduct(name: sortNameZA)

        let sortButton = app.buttons["Сортировка"]
        XCTAssertTrue(sortButton.exists, "Кнопка 'Сортировка' должна существовать")
        sortButton.tap()

        let sortByNameButton = app.buttons["По имени, я..а"]
        XCTAssertTrue(sortByNameButton.exists, "Кнопка сортировки 'По имени, я..а' должна существовать")
        sortByNameButton.tap()

        XCTAssertTrue(app.cells.firstMatch.staticTexts[sortNameZA].exists, "Первый элемент должен иметь текст '\(sortNameZA)' после сортировки")
    }
}
