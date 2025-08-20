using System.Threading;
using System.Threading.Tasks;

namespace Edory.SharedKernel.CQRS;

/// <summary>
/// Interface für Query Handler
/// </summary>
/// <typeparam name="TQuery">Typ der Query</typeparam>
/// <typeparam name="TResult">Typ des Rückgabewerts</typeparam>
public interface IQueryHandler<in TQuery, TResult>
    where TQuery : class, IQuery<TResult>
{
    Task<TResult> HandleAsync(TQuery query, CancellationToken cancellationToken = default);
}
