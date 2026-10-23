package dev.giahuy.ecommerce.common.dto;

import lombok.*;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class PaginationMeta {
    int page;
    int size;
    int totalElements;
    int totalPages;
    boolean hasNext;
    boolean hasPrevious;
}
