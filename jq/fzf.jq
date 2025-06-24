def to_entries:
	.[]
	| [ .search
		, .data
		, .display[]
	]
	| @tsv
;
