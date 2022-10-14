/* ============================================================
 * This code is part of the "apex-lang" open source project avaiable at:
 * 
 *      http://code.google.com/p/apex-lang/
 *
 * This code is licensed under the Apache License, Version 2.0.  You may obtain a 
 * copy of the License at:
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================
 */
public with sharing class ObjectPaginator {

    //================================================
    // CONSTRUCTORS    
    //================================================
    public ObjectPaginator(){
        this(DEFAULT_PAGE_SIZE, DEFAULT_PAGE_SIZE_OPTIONS, DEFAULT_SKIP_SIZE, null);
    } 
    
    public ObjectPaginator(    ObjectPaginatorListener listener ){
        this(DEFAULT_PAGE_SIZE, DEFAULT_PAGE_SIZE_OPTIONS, DEFAULT_SKIP_SIZE, listener);
    }
     
    /*
    public ObjectPaginator(    Integer skipSize){
        this(DEFAULT_PAGE_SIZE, DEFAULT_PAGE_SIZE_OPTIONS, skipSize, null);
    } 
    
    public ObjectPaginator(    Integer skipSize,
                            ObjectPaginatorListener listener){
        this(DEFAULT_PAGE_SIZE, DEFAULT_PAGE_SIZE_OPTIONS, skipSize, listener);
    }*/
     
    public ObjectPaginator(    List<Integer> pageSizeIntegerOptions ){
        this(DEFAULT_PAGE_SIZE, pageSizeIntegerOptions, DEFAULT_SKIP_SIZE, null);
    }
     
    public ObjectPaginator(    List<Integer> pageSizeIntegerOptions,
                            ObjectPaginatorListener listener ){
        this(DEFAULT_PAGE_SIZE, pageSizeIntegerOptions, DEFAULT_SKIP_SIZE, listener);
    } 
    
    public ObjectPaginator(    List<Integer> pageSizeIntegerOptions,
                            Integer skipSize ){
        this(DEFAULT_PAGE_SIZE, pageSizeIntegerOptions, skipSize, null);
    } 
    
    public ObjectPaginator( List<Integer> pageSizeIntegerOptions,
                            Integer skipSize,
                             ObjectPaginatorListener listener ){
        this(DEFAULT_PAGE_SIZE, pageSizeIntegerOptions, skipSize, listener);
    } 
    
    public ObjectPaginator(    Integer pageSize ){
        this(pageSize, DEFAULT_PAGE_SIZE_OPTIONS, DEFAULT_SKIP_SIZE, null);
    }
     
    public ObjectPaginator(    Integer pageSize,
                            ObjectPaginatorListener listener ){
        this(pageSize, DEFAULT_PAGE_SIZE_OPTIONS, DEFAULT_SKIP_SIZE, listener);
    } 
    
    public ObjectPaginator(    Integer pageSize,
                            Integer skipSize ){
        this(pageSize, DEFAULT_PAGE_SIZE_OPTIONS, skipSize, null);
    }
     
    public ObjectPaginator(    Integer pageSize,
                            Integer skipSize,
                            ObjectPaginatorListener listener ){
        this(pageSize, DEFAULT_PAGE_SIZE_OPTIONS, skipSize, listener);
    } 
    
    public ObjectPaginator(    Integer pageSize,
                            List<Integer> pageSizeIntegerOptions){
        this(pageSize, pageSizeIntegerOptions, DEFAULT_SKIP_SIZE, null);
    }
     
    public ObjectPaginator(    Integer pageSize,
                            List<Integer> pageSizeIntegerOptions,
                            ObjectPaginatorListener listener){
        this(pageSize, pageSizeIntegerOptions, DEFAULT_SKIP_SIZE, listener);
    }
     
    public ObjectPaginator(    Integer pageSize,
                            List<Integer> pageSizeIntegerOptions,
                            Integer skipSize){
        this(pageSize, pageSizeIntegerOptions, skipSize, null);
    }
     
    public ObjectPaginator(    Integer pageSize, 
                            List<Integer> pageSizeIntegerOptions, 
                            Integer skipSize, 
                            ObjectPaginatorListener listener){
        this.listeners = new List<ObjectPaginatorListener>();                                
        setPageSize(pageSize);
        setPageSizeOptions(pageSizeIntegerOptions);
        setSkipSize(skipSize);
        addListener(listener);
    }

    //================================================
    // CONSTANTS    
    //================================================
    public static final     Integer         DEFAULT_PAGE_SIZE             = 20;
    public static final     List<Integer>   DEFAULT_PAGE_SIZE_OPTIONS     = new List<Integer>{10,20,50,100,200};
    public static final     Integer         DEFAULT_SKIP_SIZE             = 3;
    public static final     Integer         MAX_SKIP_SIZE                 = 20;

    //================================================
    // PROPERTIES    
    //================================================
    public List<Object>                     all                     {get;private set;}
    public List<Object>                     page                    {get;private set;}
    public Integer                          pageSize                {get;private set;} 
    public List<Integer>                    pageSizeIntegerOptions  {get;private set;} 
    public List<SelectOption>               pageSizeSelectOptions   {get;private set;} 
    public Integer                          skipSize                {get;private set;}
    public Integer                          pageNumber              {get;private set;}
    public List<ObjectPaginatorListener>    listeners               {get;private set;}    

    //================================================
    // DERIVED PROPERTIES    
    //================================================
    public Integer pageCount { 
        get{ 
            Double allSize = this.all == null ? 0 : this.all.size(); 
            Double pageSize = this.pageSize; 
            return this.all == null ? 0 : Math.ceil(allSize/pageSize).intValue(); 
        } 
    }
    
    public Integer recordCount {
        get{ 
            return this.all == null ? 0 : this.all.size(); 
        } 
    }
    
    public Boolean hasNext{
        get{ 
            return pageNumber >= 0 && pageNumber < this.pageCount-1;
        }
    }
    
    public Boolean hasPrevious{
        get{
            return pageNumber > 0 && pageNumber <= this.pageCount-1;
        }
    }
    
    public Integer pageStartPosition {
        get{ 
            return this.pageNumber * this.pageSize; 
        } 
    }
    
    public Integer pageEndPosition {
        get{ 
            Integer endPosition = (this.pageNumber + 1) * this.pageSize - 1;
            endPosition = endPosition < recordCount ? endPosition : recordCount-1;
            return endPosition; 
        } 
    }
    public List<Integer> previousSkipPageNumbers {
        get{
            List<Integer> returnValues = new List<Integer>();
            for(Integer i = skipSize; i > 0; i--){
                if(pageNumber-i < 0){
                    continue;
                }
                returnValues.add(pageNumber-i);
            }
            return returnValues;
        }
    }
    
    public List<Integer> nextSkipPageNumbers {
        get{
            List<Integer> returnValues = new List<Integer>();
            for(Integer i = 1; i <= skipSize; i++){
                if(pageNumber+i >= pageCount){
                    break;
                }
                returnValues.add(pageNumber+i);
            }
            return returnValues;
        }
    }

    public Integer pageNumberDisplayFriendly {
        get{ 
            return this.pageNumber + 1; 
        } 
    }
    
    public Integer pageStartPositionDisplayFriendly {
        get{ 
            return this.pageStartPosition + 1; 
        } 
    }
    
    public Integer pageEndPositionDisplayFriendly {
        get{ 
            return this.pageEndPosition + 1; 
        } 
    }

    //================================================
    // METHODS    
    //================================================
    public void setRecords(List<Object> all){
        reset(all,this.pageSize);
    }
    
    public void setPageSize(Integer pageSize){
        if(this.pageSize!=pageSize){
            reset(this.all,pageSize);
        }
    }
    
    public Integer getPageSize(){
        return this.pageSize;
    }

    public void setPageSizeOptions(List<Integer> pageSizeIntegerOptions){
        this.pageSizeIntegerOptions = pageSizeIntegerOptions;
        if(this.pageSizeSelectOptions == null){
            this.pageSizeSelectOptions = new List<SelectOption>();
        }
        this.pageSizeSelectOptions.clear();
        if(pageSizeIntegerOptions != null && pageSizeIntegerOptions.size() > 0){
            for(Integer pageSizeOption : pageSizeIntegerOptions){
                if(pageSizeOption < 1){
                    continue;
                }
                this.pageSizeSelectOptions.add(new SelectOption(''+pageSizeOption,''+pageSizeOption));
            }
        }
    }
    
    public List<SelectOption> getPageSizeOptions(){
        return this.pageSizeSelectOptions;
    }

    public void setSkipSize(Integer skipSize){
        this.skipSize = skipSize < 0 || skipSize > MAX_SKIP_SIZE ? this.skipSize : skipSize;
    }
    
    public PageReference skipToPage(Integer pageNumber){
        if(pageNumber < 0 || pageNumber > this.pageCount-1){
            throw new IllegalArgumentException();
        }
        this.pageNumber = pageNumber;
        updatePage();
        return null;
    }
    
    public PageReference next(){
        if(!this.hasNext){
            throw new IllegalStateException();
        }
        this.pageNumber++;
        updatePage();
        return null;
    }
    
    public PageReference previous(){
        if(!this.hasPrevious){
            throw new IllegalStateException();
        }
        this.pageNumber--;
        updatePage();
        return null;
    }
    
    public PageReference first(){
        this.pageNumber = 0;
        updatePage();
        return null;
    }
    
    public PageReference last(){
        this.pageNumber = pageCount - 1;
        updatePage();
        return null;
    }
    
    private void reset(List<Object> all, Integer pageSize){
        this.all = all;
        this.pageSize = pageSize < 1 ? DEFAULT_PAGE_SIZE : pageSize;
        this.pageNumber = 0;
        updatePage();
    }

    private void updatePage() {
        this.page = null;
        if(this.all != null && this.all.size() > 0){
            this.page = new List<Object>();
            for (Integer i = this.pageStartPosition; i <= this.pageEndPosition; i++) {
                this.page.add(this.all.get(i));
            }
        }
        firePageChangeEvent();
    }
     
    public void addListener(ObjectPaginatorListener listener){
        if(listener != null){
            listeners.add(listener);
        }
    }

    public void firePageChangeEvent(){
        for(ObjectPaginatorListener listener : listeners){
            listener.handlePageChange(this.page);
        }
    }
}