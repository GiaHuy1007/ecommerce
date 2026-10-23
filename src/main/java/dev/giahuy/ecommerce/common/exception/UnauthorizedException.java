package dev.giahuy.ecommerce.common.exception;

public class UnauthorizedException extends BusinessException{
    public UnauthorizedException() {
        super(ErrorCode.INVALID_CREDENTIALS);
    }
}
