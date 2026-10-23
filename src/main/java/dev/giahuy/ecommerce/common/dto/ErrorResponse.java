package dev.giahuy.ecommerce.common.dto;

import lombok.*;

import java.time.Instant;
import java.util.List;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ErrorResponse {
    private boolean success;
    private String code;
    private String message;
    private String path;
    private String traceId;
    List<FieldError> fieldErrors;
    Instant timestamp;
}
