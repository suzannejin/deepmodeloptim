# First file (ex. chrom_sizes.txt): Load chromosome sizes into an array
NR==FNR { chrom_sizes[$1] = $2; next; }

# Second file (ex. input.bed): Process BED data
# Print header lines as they are
/^#/ { print; next; }
{
    mid = $4;                  # extract peak piosition
    left = int(N/2);           # Floor division for left padding
    right = N - left - 1;      # Ensures total length is exactly N

    # the new start and end values
    start = mid - left;
    ends = mid + right;

    # Ensure start is not negative
    if (start < 0) start = 0;

    # Ensure end does not exceed chromosome size
    if ($1 in chrom_sizes && ends > chrom_sizes[$1]) {
        ends = chrom_sizes[$1];
    }

    # Print updated start, end, and ALL remaining columns
    printf "%s\t%d\t%d", $1, start, ends;
    for (i=4; i<=NF; i++) {
        printf "\t%s", $i;
    }
    print "";  # Newline
}