package dev.giahuy.ecommerce.common.dto;

import lombok.*;

import java.time.Instant;
import java.util.List;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class PageResponse<T> {
    List<T> items;
    PaginationMeta paginationMeta;
    Instant timestamp;
}
