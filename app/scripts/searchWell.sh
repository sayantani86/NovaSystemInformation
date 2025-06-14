PGPASSWORD="avon123" psql -U $1 -d $2 -c "SELECT * FROM searchWellInIronIQ('$3');" 
