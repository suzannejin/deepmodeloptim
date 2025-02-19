BEGIN {
    # Read chromosome sizes into an array
    while ((getline < chrom_size_file) > 0) {
        chrom_sizes[$1] = $2;
    }
}
# Print header lines as they are
/^#/ { print; next; }
{
    mid = $4;                  # extract peak piosition
    left = int(N/2);           # Floor division for left padding
    right = N - left - 1;      # Ensures total length is exactly N

    # the new start and end values
    start = mid - left;
    end = mid + right;

    # Ensure start is not negative
    if (start < 0) start = 0;

    # Ensure end does not exceed chromosome size
    if ($1 in chrom_sizes && end > chrom_sizes[$1]) {
        end = chrom_sizes[$1];
    }

    # Print updated start, end, and ALL remaining columns
    printf "%s\t%d\t%d", $1, start, end;
    for (i=4; i<=NF; i++) {
        printf "\t%s", $i;
    }
    print "";  # Newline
}