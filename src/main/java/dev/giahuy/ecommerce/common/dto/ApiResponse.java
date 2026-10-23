package dev.giahuy.ecommerce.common.dto;

import lombok.*;

import java.time.Instant;
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ApiResponse<T> {
    private boolean success;
    private String code;
    private String message;
    private T data;
    private Instant timestamp;
}
