enum ov680_tok_type {
        OV680_8BIT  = 0x0001,
        OV680_16BIT = 0x0002,
        OV680_TOK_TERM   = 0xf000,      /* terminating token for reg list */
        OV680_TOK_DELAY  = 0xfe00       /* delay token for reg list */
};

/**
 * struct ov680_reg - 680 sensor  register format
 * @reg: 16-bit offset to register
 * @val: 8-bit register value
 */
struct ov680_reg {
        enum ov680_tok_type type;
        unsigned short reg;
        unsigned char val;
};

