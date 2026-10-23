package dev.giahuy.ecommerce.common.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum ErrorCode {
    // ==================== COMMON ====================
    VALIDATION_ERROR(
            "COMMON_001",
            "Invalid input data",
            HttpStatus.BAD_REQUEST
    ),
    MALFORMED_JSON(
            "COMMON_002",
            "Invalid JSON format or parameter type",
            HttpStatus.BAD_REQUEST
    ),
    RESOURCE_NOT_FOUND(
            "COMMON_003",
            "The requested resource was not found",
            HttpStatus.NOT_FOUND
    ),
    DUPLICATE_RESOURCE(
            "COMMON_004",
            "Resource already exists",
            HttpStatus.CONFLICT
    ),
    RATE_LIMIT_EXCEEDED(
            "COMMON_005",
            "Too many requests. Please try again later",
            HttpStatus.TOO_MANY_REQUESTS
    ),
    INTERNAL_SERVER_ERROR(
            "COMMON_999",
            "The system is currently unavailable. Please try again later",
            HttpStatus.INTERNAL_SERVER_ERROR
    ),

    // ==================== AUTH ====================
    INVALID_CREDENTIALS(
            "AUTH_001",
            "Invalid email or password",
            HttpStatus.UNAUTHORIZED
    ),
    EMAIL_NOT_VERIFIED(
            "AUTH_002",
            "Email address has not been verified",
            HttpStatus.FORBIDDEN
    ),
    ACCOUNT_LOCKED(
            "AUTH_003",
            "Account has been locked",
            HttpStatus.FORBIDDEN
    ),
    TOKEN_EXPIRED(
            "AUTH_004",
            "Authentication token has expired",
            HttpStatus.UNAUTHORIZED
    ),
    TOKEN_INVALID(
            "AUTH_005",
            "Invalid or revoked token",
            HttpStatus.UNAUTHORIZED
    ),
    ACCESS_DENIED(
            "AUTH_006",
            "You do not have permission to perform this action",
            HttpStatus.FORBIDDEN
    ),
    VERIFICATION_TOKEN_INVALID(
            "AUTH_007",
            "Verification token is invalid or has expired",
            HttpStatus.BAD_REQUEST
    ),

    // ==================== USER ====================
    EMAIL_ALREADY_EXISTS(
            "USER_001",
            "This email address is already registered",
            HttpStatus.CONFLICT
    ),
    PHONE_ALREADY_EXISTS(
            "USER_002",
            "This phone number is already in use",
            HttpStatus.CONFLICT
    ),
    OLD_PASSWORD_MISMATCH(
            "USER_003",
            "Current password is incorrect",
            HttpStatus.BAD_REQUEST
    ),
    ADDRESS_LIMIT_EXCEEDED(
            "USER_004",
            "You can have a maximum of 10 shipping addresses",
            HttpStatus.BAD_REQUEST
    ),

    // ==================== CATEGORY & PRODUCT ====================
    CATEGORY_SLUG_EXISTS(
            "CAT_001",
            "Category slug already exists",
            HttpStatus.CONFLICT
    ),
    CATEGORY_HAS_CHILDREN_OR_PRODUCTS(
            "CAT_002",
            "Cannot delete a category that contains subcategories or products",
            HttpStatus.BAD_REQUEST
    ),
    PRODUCT_SLUG_EXISTS(
            "CAT_003",
            "Product slug already exists",
            HttpStatus.CONFLICT
    ),
    VARIANT_SKU_EXISTS(
            "CAT_004",
            "Product variant SKU already exists",
            HttpStatus.CONFLICT
    ),
    VARIANT_DUPLICATE_SIZE_COLOR(
            "CAT_005",
            "A variant with this size and color already exists for this product",
            HttpStatus.CONFLICT
    ),
    INVALID_SALE_PRICE(
            "CAT_006",
            "Sale price must be lower than the original price",
            HttpStatus.BAD_REQUEST
    ),
    PRODUCT_INACTIVE(
            "CAT_007",
            "This product is currently unavailable",
            HttpStatus.BAD_REQUEST
    ),

    // ==================== INVENTORY ====================
    INVENTORY_NOT_FOUND(
            "INV_001",
            "Inventory record for this product variant was not found",
            HttpStatus.NOT_FOUND
    ),
    INSUFFICIENT_STOCK(
            "INV_002",
            "Insufficient available stock",
            HttpStatus.CONFLICT
    ),
    NEGATIVE_STOCK_ADJUSTMENT(
            "INV_003",
            "Stock adjustment cannot reduce on-hand quantity below reserved quantity",
            HttpStatus.BAD_REQUEST
    ),

    // ==================== CART ====================
    CART_EMPTY(
            "CART_001",
            "Your shopping cart is empty",
            HttpStatus.BAD_REQUEST
    ),
    CART_ITEM_NOT_FOUND(
            "CART_002",
            "Item not found in the shopping cart",
            HttpStatus.NOT_FOUND
    ),
    CART_MAX_QUANTITY_EXCEEDED(
            "CART_003",
            "Maximum quantity per product variant is 50",
            HttpStatus.BAD_REQUEST
    ),

    // ==================== VOUCHER ====================
    VOUCHER_NOT_FOUND(
            "VOU_001",
            "Voucher code not found",
            HttpStatus.NOT_FOUND
    ),
    VOUCHER_INACTIVE_OR_EXPIRED(
            "VOU_002",
            "Voucher has not started yet or has expired",
            HttpStatus.BAD_REQUEST
    ),
    VOUCHER_USAGE_LIMIT_REACHED(
            "VOU_003",
            "Voucher usage limit has been reached",
            HttpStatus.CONFLICT
    ),
    VOUCHER_USER_LIMIT_REACHED(
            "VOU_004",
            "You have reached the usage limit for this voucher",
            HttpStatus.BAD_REQUEST
    ),
    VOUCHER_MIN_ORDER_NOT_MET(
            "VOU_005",
            "Order does not meet the minimum amount required for this voucher",
            HttpStatus.BAD_REQUEST
    ),
    VOUCHER_SCOPE_NOT_APPLICABLE(
            "VOU_006",
            "This voucher does not apply to the products in your order",
            HttpStatus.BAD_REQUEST
    ),

    // ==================== ORDER ====================
    ORDER_NOT_FOUND(
            "ORD_001",
            "Order not found",
            HttpStatus.NOT_FOUND
    ),
    INVALID_STATUS_TRANSITION(
            "ORD_002",
            "Cannot change order status from {from} to {to}",
            HttpStatus.BAD_REQUEST
    ),
    ORDER_CANNOT_BE_CANCELLED(
            "ORD_003",
            "This order cannot be cancelled because it has entered the shipping stage",
            HttpStatus.BAD_REQUEST
    ),
    DUPLICATE_ORDER_SUBMISSION(
            "ORD_004",
            "This order request is already being processed",
            HttpStatus.CONFLICT
    ),
    PRICE_CHANGED_AT_CHECKOUT(
            "ORD_005",
            "Product prices have changed. Please review your cart",
            HttpStatus.CONFLICT
    ),
    RETURN_WINDOW_EXPIRED(
            "ORD_006",
            "The 7-day return window has expired",
            HttpStatus.BAD_REQUEST
    ),

    // ==================== PAYMENT ====================
    PAYMENT_SIGNATURE_INVALID(
            "PAY_001",
            "Invalid payment security signature",
            HttpStatus.BAD_REQUEST
    ),
    PAYMENT_AMOUNT_MISMATCH(
            "PAY_002",
            "Payment amount does not match the order total",
            HttpStatus.BAD_REQUEST
    ),
    ORDER_PAYMENT_EXPIRED(
            "PAY_003",
            "The payment deadline has expired",
            HttpStatus.BAD_REQUEST
    ),

    // ==================== REVIEW ====================
    REVIEW_NOT_ELIGIBLE(
            "REV_001",
            "You can only review products after completing an eligible order",
            HttpStatus.FORBIDDEN
    ),
    REVIEW_ALREADY_EXISTS(
            "REV_002",
            "You have already reviewed this product for this order item",
            HttpStatus.CONFLICT
    ),

    // ==================== FILE ====================
    FILE_INVALID_TYPE(
            "FILE_001",
            "Only JPG, PNG, and WEBP image formats are supported",
            HttpStatus.BAD_REQUEST
    ),
    FILE_SIZE_EXCEEDED(
            "FILE_002",
            "File size exceeds the maximum allowed limit of 5 MB",
            HttpStatus.BAD_REQUEST
    )
    ;
    private final String code;
    private final String message;
    private final HttpStatus httpStatus;
}
