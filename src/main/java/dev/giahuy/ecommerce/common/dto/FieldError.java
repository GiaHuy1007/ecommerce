package dev.giahuy.ecommerce.common.dto;

import lombok.*;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class FieldError {
    private String field;
    private String rejectedValue;
    private String message;
}
