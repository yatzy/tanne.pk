'%ni%' = Negate('%in%')

# can't handle errors
get_point_call_object = function( call_object , lat=lat , lon=lon , radius=radius ){
  # formats statmet eq ala_asteet = get_ala_asteet(60.18288, 24.922 , 1)
  call_name = sprintf( '%s = get_%s( %f , %f , %f )' ,call_object , call_object , lat , lon , radius )
  return(  eval(parse(text = call_name)) ) 
}

# can't handle errors
get_zip_call_object = function( call_object , zip=zip ){
  # formats statmet eq ala_asteet = get_ala_asteet(60.18288, 24.922 , 1)
  call_name = sprintf( '%s = get_%s( zippify(%s) )' ,call_object , call_object , zip )
  return(  eval(parse(text = call_name)) ) 
}

nth_max <- function(x, N=1){
  len <- length(x)
  if(N>len){
    warning('N greater than length(x).  Setting N=length(x)')
    N <- length(x)
  }
  res = which(x == sort(x,partial=len-N+1)[len-N+1]) 
  res = names(res[1])
}

is_empty <- function(x) {
  return(identical(x, numeric(0)))
}


###################### paskaa

# strongify <- function(func){
#   function(...){
#     tryCatch({
#       func(...)
#     },
#     error=function(e){
#       return(NA)
#     }
#   })
# }

# strongify <- function(func){
#   function(...){
#     try(func(...))
#     if(class())
#     }
# }

# get_call_object = strongify(get_call_object_weak)

# lat = 60.18288
# lon = 24.922
# ala_asteet = get_ala_asteet(lat, lon , radius)
# yla_asteet = get_yla_asteet(lat, lon , radius)
# ruokakaupat = get_ruokakaupat(lat, lon , radius)


# elements <- list(1:10, c(-1, 10), c(T, F), letters)
# results <- lapply(elements, log)
# #> Warning in FUN(X[[i]], ...): NaNs produced
# #> Error in FUN(X[[i]], ...): non-numeric argument to mathematical function
# results <- lapply(elements, function(x) try(log(x)))
