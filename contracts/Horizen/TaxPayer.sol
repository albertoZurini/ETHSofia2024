// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title TaxPayer - A contract for managing tax applications using zkProofs and attestations with stablecoin payments
/// @notice This contract allows users to submit tax applications, government to verify and accept them, and users to pay the taxes in stablecoins.
/// @dev This contract uses structured data and state transitions to prevent rollback of tax application states.

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool success);
}

contract TaxPayer {

    /// @notice The stablecoin used for tax payments (e.g., USDC, USDT)
    IERC20 public immutable stablecoin;

    /// @notice The government address responsible for verifying and accepting tax applications
    /// @dev This is a constant and should be set at contract deployment
    address public government;

    /// @notice Struct representing a tax application submitted by a user
    struct TaxApplication {
        address user;            // User's address
        uint8 taxYear;           // Tax year for the application
        string contentHash;      // URL of the zkProof JSON file
        bytes32 attestationId;   // Attestation ID after government verification (null before verification)
        uint256 amountTaxDue;    // Amount of tax that is due (0 after payment)
    }

    /// @notice Mapping of taxId to TaxApplication struct
    mapping(bytes32 => TaxApplication) public taxApplications;

    /// @notice Event emitted when a new tax application is filled
    /// @param taxId Unique ID of the tax application
    /// @param user Address of the user who submitted the tax application
    /// @param taxYear Tax year for which the application is filed
    /// @param contentHash URL of the zkProof JSON file
    event TaxApplicationFilled(bytes32 indexed taxId, address indexed user, uint8 taxYear, string contentHash);

    /// @notice Event emitted when a tax application is accepted by the government
    /// @param taxId Unique ID of the tax application
    /// @param attestationId Attestation ID provided by the government
    /// @param amountTaxDue Amount of tax to be paid
    event TaxApplicationAccepted(bytes32 indexed taxId, bytes32 attestationId, uint256 amountTaxDue);

    /// @notice Event emitted when a tax application is rejected due to an amount mismatch
    /// @param taxId Unique ID of the tax application
    /// @param attestationId Attestation ID provided by the government
    /// @param amountTaxDue Amount of tax to be paid given by the proof
    event TaxApplicationRejected(bytes32 indexed taxId, bytes32 attestationId, uint256 amountTaxDue);

    /// @notice Event emitted when a tax payment is made
    /// @param taxId Unique ID of the tax application
    /// @param amountPaid Amount of tax paid
    event TaxesPaid(bytes32 indexed taxId, uint256 amountPaid);

    /// @notice Error thrown when a function is called by a non-government address
    error NotGovernment();

    /// @notice Error thrown when an invalid taxId is provided
    error InvalidTaxId();

    /// @notice Error thrown when an action is attempted at an incorrect stage in the process
    error InvalidStage();

    /// @notice Error thrown when the provided amount does not match the expected amount
    error AmountMismatch();

    /// @dev Modifier to restrict functions to only the government address
    modifier onlyGovernment() {
        if (msg.sender != government) revert NotGovernment();
        _;
    }

    /// @param _stablecoin Address of the stablecoin contract (e.g., USDC or USDT)
    constructor(IERC20 _stablecoin) {
        stablecoin = _stablecoin;
        government = msg.sender;
    }

    /// @notice Function to fill a new tax application
    /// @dev This function generates a taxId based on the user address and tax year, and initializes the tax application
    /// @param contentHash The URL of the zkProof JSON file
    /// @param amountTaxDue The amount of tax the user owes
    /// @return taxId The unique ID of the tax application
    function fillTaxApplication(string memory contentHash, uint256 amountTaxDue) external returns (bytes32 taxId) {
        uint8 taxYear = uint8(block.timestamp / 31556926); // Approximate year since 1970
        taxId = keccak256(abi.encodePacked(msg.sender, taxYear));

        if (taxApplications[taxId].user != address(0)) revert InvalidTaxId(); // Ensure taxId is unique

        taxApplications[taxId] = TaxApplication({
            user: msg.sender,
            taxYear: taxYear,
            contentHash: contentHash,
            attestationId: 0,
            amountTaxDue: amountTaxDue
        });

        emit TaxApplicationFilled(taxId, msg.sender, taxYear, contentHash);
    }

    /// @notice Function for the government to accept and verify a tax application
    /// @dev The government must provide the attestationId and the amountTaxDue must match the user's declaration
    /// @param taxId The unique ID of the tax application
    /// @param attestationId The attestation ID after verification
    /// @param amountTaxDue The verified amount of tax due
    function acceptTaxApplication(bytes32 taxId, bytes32 attestationId, uint256 amountTaxDue) external onlyGovernment {
        TaxApplication storage app = taxApplications[taxId];

        if (app.user == address(0)) revert InvalidTaxId(); // Tax application must exist
        if (app.attestationId != 0) revert InvalidStage(); // Cannot accept a tax application twice
        if (app.amountTaxDue != amountTaxDue) {
            taxApplications[taxId].user = address(0);
            emit TaxApplicationRejected(taxId, attestationId, amountTaxDue); // Trigger rejection event on mismatch
            return; // Cancel the tax application
        }

        app.attestationId = attestationId;

        emit TaxApplicationAccepted(taxId, attestationId, amountTaxDue);
    }

    /// @notice Function for users to pay their taxes in stablecoins
    /// @dev The user must pay the exact amount of tax due, and once paid, the process is finalized
    /// @param taxId The unique ID of the tax application
    function payTaxes(bytes32 taxId) external {
        TaxApplication storage app = taxApplications[taxId];

        if (app.user == address(0)) revert InvalidTaxId(); // Tax application must exist
        if (app.attestationId == 0) revert InvalidStage(); // Application must be verified
        if (app.amountTaxDue == 0) revert InvalidStage(); // No taxes due

        // Transfer the tax payment to the government
        if (!stablecoin.transferFrom(msg.sender, government, app.amountTaxDue)) {
            revert AmountMismatch();
        }

        // Mark the tax as paid
        uint256 amountPaid = app.amountTaxDue;
        app.amountTaxDue = 0;

        emit TaxesPaid(taxId, amountPaid);
    }
}
