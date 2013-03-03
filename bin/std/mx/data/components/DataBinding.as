[RequiresDataBinding(true)]
[IconFile("DataBindingClasses.png")]
class mx.data.components.DataBinding extends MovieClip
{
	function Dummy()
	{
		new mx.data.binding.Binding();
		new mx.data.binding.ComponentMixins();
		new mx.data.binding.CustomFormatter();
		new mx.data.binding.CustomValidator();
		new mx.data.binding.DataAccessor();
		new mx.data.binding.DataType();
		new mx.data.binding.DateBase();
		new mx.data.binding.Encoder();
		new mx.data.binding.EndPoint();
		new mx.data.binding.FieldAccessor();
		new mx.data.binding.Formatter();
		new mx.data.binding.Kind();
		new mx.data.binding.Log();
		new mx.data.binding.TypedValue();
		
		new mx.utils.ClassFinder();
		new mx.utils.Collection();
		new mx.utils.CollectionImpl();
		new mx.utils.Iterator();
		new mx.utils.IteratorImpl();
		new mx.utils.StringFormatter();
		new mx.utils.StringTokenParser();
	}
}
