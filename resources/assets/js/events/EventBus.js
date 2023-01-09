// eventBus.js
const Emitter = require( "tiny-emitter" );

class EventBus {
  constructor(){
    this.emitter = new Emitter();
  }
  $on(...args){ return this.emitter.on(...args)}
  $once(...args){return this.emitter.once(...args)}
  $off( event, callback = null ){
    if ( Array.isArray( event ) ){
      event.forEach( singleEvent => this.emitter.off( singleEvent, callback ) )
    } else {
      this.emitter.off( event, callback )
    }
  }
  $emit(...args){ return this.emitter.emit(...args) }
}

export default EventBus;